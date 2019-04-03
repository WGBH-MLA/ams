require 'zip'
#NEW NEW NEW 
# module AMS::Export
# The module used to export the zip file containing PBCore XMLs
module AMS::Export
  # Class is responsible for generating the zip file containing the PBCore xml files.
  class DocumentsToZippedPbcore < ExportService
    def initialize(solr_documents, options={}, format = 'zip', filename = nil)
      super
      puts self.format
    end

    def process_export
      Sidekiq::Logging.logger.warn "Making Zip File right NOW"

      # Dir.mktmpdir do |dir|

      #   @solr_documents.each do |doc|
      #     file_name = "#{doc.id}.xml"
      #     File.open("#{dir}/#{file_name}", 'w') do |f|
      #       f << doc.export_as_pbcore
      #     end
      #   end

      #   `cd #{File.dirname(dir)} && zip -r #{dir} #{@file_path.path}`
      # end

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
