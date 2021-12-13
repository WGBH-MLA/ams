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
        Nokogiri::XML(open(path)) { |config| config.strict }.remove_namespaces!
      end
    end

    def self.data_for_entry(data, source_id)
      collections = []
      children = []
      xpath_for_source_id = ".//*[name()='#{source_id}']"
      return {
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
      self.parsed_metadata['admin_data_gid'] = build_annotations(self.raw_metadata['annotations']) if self.raw_metadata['annotations'].present?
      self.parsed_metadata[work_identifier] = self.raw_metadata[source_identifier]
      self.parsed_metadata['model'] = raw_metadata['model']
      self.parsed_metadata['pbcore_xml'] = self.raw_metadata['pbcore_xml'] if self.raw_metadata['pbcore_xml'].present?
      self.parsed_metadata['skip_file_upload_validation'] = self.raw_metadata['skip_file_upload_validation'] if self.raw_metadata['skip_file_upload_validation'] == true
      self.raw_metadata.each do |key, value|
       add_metadata(key_without_numbers(key), value)
      end
      self.parsed_metadata['format'] = self.raw_metadata['format'] if self.raw_metadata['model'] == 'DigitalInstantiation'
      add_visibility
      add_rights_statement
      add_admin_set_id
      add_collections
      self.parsed_metadata['file'] = self.raw_metadata['file']
      add_local
      self.parsed_metadata
    end

    def build_annotations(annotations)
      asset_id = self.raw_metadata['Asset.id'].strip if self.raw_metadata.keys.include?('Asset.id')
      work = Asset.find(asset_id) if asset_id.present?
      admin_data_gid = if work.present?
                         work.admin_data_gid
                       else
                         AdminData.create.gid
                       end
      
      annotations.each do |annotation|
        raise "annotation_type not registered with the AnnotationTypesService: #{annotation['annotation_type']}." if annotation['annotation_type'].nil?

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

      admin_data_gid
    end
  end
end
