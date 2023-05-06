# frozen_string_literal: true

require 'nokogiri'

module Bulkrax
  class PbcoreXmlEntry < XmlEntry
    def self.read_data(path)
      if MIME::Types.type_for(path).include?('text/csv')
        CSV.read(path,
          headers: true,
          encoding: 'utf-8')
      else
        # This doesn't cope with BOM sequences:
        Nokogiri::XML(open(path), &:strict).remove_namespaces!
      end
    end

    def self.data_for_entry(data, source_id)
      collections = []
      children = []
      xpath_for_source_id = ".//*[name()='#{source_id}']"
      {
        source_id => data.xpath(xpath_for_source_id).first.text.gsub('cpb-aacip/', 'cpb-aacip-'),
        delete: data.xpath(".//*[name()='delete']").first&.text,
        data:
          data.to_xml(
            encoding: 'UTF-8',
            save_with:
              Nokogiri::XML::Node::SaveOptions::NO_DECLARATION | Nokogiri::XML::Node::SaveOptions::NO_EMPTY_TAGS
          ).delete("\n").delete("\t").squeeze(' '), # Remove newlines, tabs, and extra whitespace
        collection: collections,
        children: children
      }
    end

    def build_metadata
      raise StandardError, 'Record not found' if record.nil?

      self.parsed_metadata = {}
      self.parsed_metadata[work_identifier] = self.raw_metadata[source_identifier]
      self.parsed_metadata['model'] = self.raw_metadata['model']
      if self.raw_metadata['model'] == 'DigitalInstantiation'
        self.parsed_metadata['pbcore_xml'] = self.raw_metadata['pbcore_xml'] if self.raw_metadata['pbcore_xml'].present?
        self.parsed_metadata['format'] = self.raw_metadata['format']
        self.parsed_metadata['skip_file_upload_validation'] = self.raw_metadata['skip_file_upload_validation'] if self.raw_metadata['skip_file_upload_validation'] == true
      end

      self.raw_metadata.each do |key, value|
        add_metadata(key_without_numbers(key), value)
      end

      if self.raw_metadata['model'] == 'Asset'
        bulkrax_importer_id = importer.id
        admin_data_gid = update_or_create_admin_data_gid(bulkrax_importer_id)

        self.parsed_metadata['bulkrax_importer_id'] = bulkrax_importer_id
        self.parsed_metadata['admin_data_gid'] = admin_data_gid
        build_annotations(self.raw_metadata['annotations'], admin_data_gid) if self.raw_metadata['annotations'].present?
      end

      add_visibility
      add_rights_statement
      add_admin_set_id
      add_collections
      self.parsed_metadata['file'] = self.raw_metadata['file']
      add_local

      self.parsed_metadata
    end

    def update_or_create_admin_data_gid(bulkrax_importer_id)
      manifest_asset_id = self.raw_metadata['Asset.id'].strip if self.raw_metadata.keys.include?('Asset.id')
      xml_asset_id = self.raw_metadata['id']
      work = Asset.where(id: manifest_asset_id || xml_asset_id).first if manifest_asset_id || xml_asset_id

      admin_data_gid =  if work.present? && work.admin_data.present?
                          work.admin_data.update!(bulkrax_importer_id: bulkrax_importer_id)
                          work.admin_data_gid
                        else
                          AdminData.create(bulkrax_importer_id: bulkrax_importer_id).gid
                        end

      admin_data_gid
    end

    def build_annotations(annotations, admin_data_gid)
      annotations.each do |annotation|
        if annotation['annotation_type'].nil?
          raise "annotation_type not registered with the AnnotationTypesService: #{annotation['annotation_type']}."
        end

        admin_data = AdminData.find_by_gid(admin_data_gid)
        Annotation.find_or_create_by(
          annotation_type: annotation['annotation_type'],
          source: annotation['source'],
          value: annotation['value'],
          annotation: annotation['annotation'],
          version: annotation['version'],
          admin_data_id: admin_data.id
        )
      end
    end
  end
end
