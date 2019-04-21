require 'zip'

module AAPB
  module BatchIngest
    class ZippedPBCoreDigitalInstantiationReader < AAPB::BatchIngest::ZippedPBCoreReader
      protected
        def perform_read
          @batch_items = unzipped_xml_file_paths.map do |unzipped_xml_file_path|
            Hyrax::BatchIngest::BatchItem.new(id_within_batch: File.basename(unzipped_xml_file_path),
                                              source_location: unzipped_manifest_path,
                                              source_data: File.read(unzipped_xml_file_path),
                                              status: :initialized)
          end
        ensure
          zip_file.close
        end

      private

        def unzipped_manifest_path
          @unzipped_manifest_path ||= unzipped_file_paths.select { |path| ['.xlsx'].include? File.extname(path) }.first
        end

        def unzipped_file_paths
          @unzipped_file_paths  ||= zip_file.glob('**/*').map do |entry|
            unzipped_file_path = File.join(extraction_path, entry.name)
            FileUtils.mkdir_p File.dirname(unzipped_file_path)
            zip_file.extract(entry, unzipped_file_path)
            unzipped_file_path
          end
        ensure
          # TODO: Be more specific, i.e. "batch is empty"?
          raise Hyrax::BatchIngest::ReaderError, I18n.t('hyrax.batch_ingest.readers.errors.invalid_batch_item_file_type', source_location: @source_location) unless @unzipped_file_paths&.present?
        end
    end
  end
end
