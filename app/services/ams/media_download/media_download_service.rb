require 'zip'
require 'sony_ci_api'

# module AMS::MediaDownload
# The module used to export a zip file containing media
module AMS
  module MediaDownload
    class MediaDownloadService
      class Success < Hash; end
      class Failure < Hash; end

      attr_reader :solr_document
      attr_reader :file_path
      attr_reader :filename
      attr_reader :errors

      def initialize(solr_document:)
        @solr_document = solr_document
        @filename = "export-#{Time.now.strftime('%m_%d_%Y_%H:%M')}.zip"
        @file_path = Tempfile.new(@filename)
        @errors = []
      end

      def process
        process_download == true ? download_success : download_failure
      end

      def self.cleanup_temp_file(temp_file: nil)
        raise 'Argument must be a TempFile' unless temp_file.is_a? Tempfile
        temp_file.close
        temp_file.unlink
      end

      private

      def ci
        credentials = YAML.load(ERB.new(File.read('config/ci.yml')).result)
        @ci ||= SonyCiBasic.new(credentials:credentials)
      end

      def process_download
        begin
          sonyci_media_file_paths = []
          ::Zip::File.open(file_path.path, Zip::File::CREATE) do |zip_file|
            solr_document['sonyci_id_ssim'].each_with_index do | id, index |
              if solr_document['sonyci_id_ssim'][(index || 0).to_i].present?
                sonyci_file_location = get_sonyci_file_location(solr_document['sonyci_id_ssim'][(index || 0).to_i])
                sonyci_file_name = parse_sonyci_file_name(sonyci_file_location)
                sonyci_file_path = generate_sonyci_file_path(sonyci_file_name)
                download_media_file(sonyci_file_path, sonyci_file_location)
                zip_file.add(sonyci_file_name, sonyci_file_path)
                sonyci_media_file_paths << sonyci_file_path
              end
            end
          end
          delete_media_files(sonyci_media_file_paths)
          true
        rescue => e
          errors << e
          false
        end
      end

      def download_success
        AMS::MediaDownload::MediaDownloadService::Success[:filename, filename, :file_path, file_path]
      end

      def download_failure
        AMS::MediaDownload::MediaDownloadService::Failure[:errors, errors, :file_path, file_path]
      end

      def download_media_file(file_path, file_location)
        File.open(file_path, 'wb') do |saved_file|
          open(file_location) do |read_file|
            saved_file.write(read_file.read)
          end
        end
      end

      def delete_media_files(array_of_files)
        array_of_files.map{ |path| File.delete(path) if File.exist?(path)}
      end

      def get_sonyci_file_location(sonyci_id)
        ci.download(sonyci_id)
      end

      def parse_sonyci_file_name(location)
        URI(location).path.split('/').last
      end

      def generate_sonyci_file_path(file_name)
        File.join(Rails.root, 'tmp', file_name)
      end
    end
  end
end
