# frozen_string_literal: true

require 'nokogiri'

module Bulkrax
  class PbcoreXmlEntry < XmlEntry
    include HasAmsMatchers
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
      self.parsed_metadata['model'] = if self.raw_metadata['model']&.match(/Resource/)
                                        self.raw_metadata['model']
                                      elsif self.raw_metadata['model'].present?
                                        "#{self.raw_metadata['model']}Resource"
                                      end


      self.raw_metadata.each do |key, value|
        # skip the ones we've already added
        next if key == 'model' || key == 'pbcore_xml' || key == 'skip_file_upload_validation'
        add_metadata(key_without_numbers(key), value)
      end

      self.parsed_metadata['label'] = nil if self.parsed_metadata['label'] == "[]"
      self.parsed_metadata['dimensions'] = nil if self.parsed_metadata['dimensions'] == "[]"
      add_visibility
      add_rights_statement
      add_admin_set_id
      add_collections
      self.parsed_metadata['file'] = self.raw_metadata['file']
      add_local

      self.parsed_metadata
    end
  end
end
