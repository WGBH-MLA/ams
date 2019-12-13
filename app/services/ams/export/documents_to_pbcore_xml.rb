require 'zip'
# module AMS::Export
# The module used to export the zip file containing PBCore XMLs
module AMS::Export
  # Class is responsible for generating the zip file containing the PBCore xml files.
  class DocumentsToPbcoreXml < ExportService
    def process_export
      tmp_hash = []
      ::Zip::File.open(@file_path.path, Zip::File::CREATE) do |zip_file|
        @solr_documents.each do |doc|
          file_name = "#{doc.id}.xml"
          tmp = Tempfile.new(file_name)
          tmp << doc.export_as_pbcore
          tmp.flush
          zip_file.add(file_name, tmp.path)
          tmp.close
          tmp_hash << tmp
        end
      end
      tmp_hash.each(&:unlink)
    end

    def clean
      @file_path.unlink
    end
  end
end
