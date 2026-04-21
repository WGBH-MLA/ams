require 'pbcore_util_api'

# Module AMS::PbcoreJSONExportExtension
# This module is an extension of blacklight to export the record in PBCore XML format
module AMS::PbcoreJSONExportExtension

  # TODO: Try commenting this out and see what hapens.
  def self.extended(document)
    document.will_export_as(:pbcore_json, "application/json")
  end

  def export_as_pbcore_json
    convert_xml_to_json
  end

  private

    def pbcore_util_api
      @pbcore_util_api ||= PBCoreUtilAPI::Client.new('config/pbcore_util_api.yml')
    end

    def convert_xml_to_json
      pbcore_xml_file = Tempfile.new(["#{id}_pbcore_xml_", '.xml'])
      pbcore_xml_file.write(export_as_pbcore)
      pbcore_xml_file.rewind
      pbcore_util_api.convert_xml_to_json_file  (pbcore_xml_file.path)
    ensure
      pbcore_xml_file.unlink
    end
end
