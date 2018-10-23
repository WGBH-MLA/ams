module AMS
  module Export
    class ExportService
      attr_reader :solr_documents
      attr_reader :format
      attr_reader :filename
      attr_reader :file_path

      def initialize(solr_documents, format, filename = nil)
        @solr_documents = solr_documents
        @format = format
        if filename.nil?
          @filename = "export-#{Time.now.strftime("%m_%d_%Y_%H:%M")}.#{format}"
        else
          @filename = filename
        end
        @file_path = Tempfile.new([@filename, ".#{@format}"])
      end

      def process
          # write invidual document here
          # csv will write csv row to output csv
          # pbcore will create xml file in a temp dir
          # pbcore will then zip the dir
      end

      def upload_to_s3 (path)
          #just upload to s3
        end
      end
    end
end