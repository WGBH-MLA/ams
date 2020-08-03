require 'zip'
require 'sony_ci_api'

# module AMS::MediaDownload
# The module used to export a zip file containing media
module AMS
  module MediaDownload
    class MediaDownloadService
      attr_reader :solr_document
      attr_reader :file_path
      attr_reader :filename

      def initialize(solr_document, format = 'zip', filename = nil)
        @solr_document = solr_document
        @format = format
        @filename = if filename.nil?
                      "export-#{Time.now.strftime('%m_%d_%Y_%H:%M')}.#{format}"
                    else
                      filename
                    end
        @file_path = Tempfile.new(@filename)
      end

      def process
        begin
          process_download
          yield
        ensure
          @file_path.close
          @file_path.unlink
        end
      end

      private

      def ci
        credentials = YAML.load(ERB.new(File.read('config/ci.yml')).result)
        @ci ||= SonyCiBasic.new(credentials:credentials)
      end

      def process_download
        generate_instantiations_on_solr_document
        sonyci_media_file_paths = []

        ::Zip::File.open(file_path.path, Zip::File::CREATE) do |zip_file|
          solr_document['media'].each_with_index do | instantiation, index |
            if solr_document['sonyci_id_ssim'][(index || 0).to_i].present?
              sonyci_file_location = get_sonyci_file_location(solr_document['sonyci_id_ssim'][(index || 0).to_i])
              sonyci_file_name = parse_sonyci_file_name(sonyci_file_location)
              sonyci_file_path = generate_sonyci_file_path(sonyci_file_name)
              download_media_file(sonyci_file_path, sonyci_file_location)
              zip_file.add(sonyci_file_name, sonyci_file_path)
              sonyci_media_file_paths << sonyci_file_path
            else
              raise "Instantiation is missing a SonyCi Identifier. Instantiation: #{instantiation}"
            end
          end
        end
        delete_media_files(sonyci_media_file_paths)
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
        CGI::parse(location)["response-content-disposition"][0].split('filename=').last.gsub("\"",'')
      end

      def generate_sonyci_file_path(file_name)
        File.join(Rails.root, 'tmp', file_name)
      end

      def generate_instantiations_on_solr_document
        solr_document['media'] = []

        solr_document.find_child(DigitalInstantiation).each do |instantiation|
          if ( instantiation_have_essence_tracks(instantiation) &&
               instantiation_have_generation_proxy(instantiation) &&
               instantiation_have_holding_organization_aapb(instantiation) )
              solr_document['media'] << instantiation
          end
        end
      end

      def instantiation_have_essence_tracks(instantiation)
        instantiation.fetch(:member_ids_ssim, []).size > 0
      end

      def instantiation_have_generation_proxy(instantiation)
        ( instantiation.generations && instantiation.generations.include?("Proxy") )
      end

      def instantiation_have_holding_organization_aapb(instantiation)
        (instantiation.holding_organization && instantiation.holding_organization.include?("American Archive of Public Broadcasting"))
      end
    end
  end
end
