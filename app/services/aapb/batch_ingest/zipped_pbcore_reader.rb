require 'zip'

module AAPB
  module BatchIngest
    class ZippedPBCoreReader < AAPB::BatchIngest::BatchReader
      protected
        def perform_read
          @batch_items = unzipped_xml_file_paths.map do |unzipped_xml_file_path|
            Hyrax::BatchIngest::BatchItem.new(id_within_batch: File.basename(unzipped_xml_file_path),
                                              source_location: unzipped_xml_file_path,
                                              status: :initialized)
          end
        ensure
          zip_file.close
        end

      private

        def unzipped_xml_file_paths
          @unzipped_xml_file_paths ||= unzipped_file_paths.select { |path| ['.pbcore', '.xml'].include? File.extname(path) }.reject { |path| path.split("/")[-1].start_with?(".") }
        ensure
          # TODO: Be more specific, i.e. "batch is missing XML files"?
          raise Hyrax::BatchIngest::ReaderError, I18n.t('hyrax.batch_ingest.readers.errors.invalid_batch_item_file_type', source_location: @source_location) unless @unzipped_xml_file_paths&.present?
        end

        def unzipped_file_paths
          @unzipped_file_paths  ||= begin
            files = zip_file.glob('**/*.xml') + zip_file.glob('**/*.pbcore')
            files.map do |entry|
              unzipped_file_path = File.join(extraction_path, entry.name)
              FileUtils.mkdir_p File.dirname(unzipped_file_path)
              zip_file.extract(entry, unzipped_file_path)
              unzipped_file_path
            end
          end
        ensure
          # TODO: Be more specific, i.e. "batch is empty"?
          raise Hyrax::BatchIngest::ReaderError, I18n.t('hyrax.batch_ingest.readers.errors.invalid_batch_item_file_type', source_location: @source_location) unless @unzipped_file_paths&.present?
        end

        def zip_file
          @zip_file ||= Zip::File.open(@source_location)
        rescue Zip::Error => e
          # TODO: Be more specific? I.e. "not a valid zip file"
          raise Hyrax::BatchIngest::ReaderError, I18n.t('hyrax.batch_ingest.readers.errors.invalid_batch_item_file_type', source_location: @source_location)
        end

        # TODO: Move to a ZippedReader module?
        def extraction_path
          # TODO: fetch extraction path from Batch ingest config, if present.
          @extraction_path ||= Rails.root.join("tmp", "imports", "batch_ingest", "#{Time.now.to_i}#{rand(1000)}")
        ensure
          FileUtils.mkdir_p @extraction_path unless Dir.exist? @extraction_path
        end
    end
  end
end
