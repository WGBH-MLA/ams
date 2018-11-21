require 'zip'

module WGBH
  module BatchIngest
    class ZippedPBCoreReader < WGBH::BatchIngest::BatchReader

      attr_reader :root_extraction_path, :extraction_path

      def initialize(*args)
        # TODO: read extraction path from config
        @root_extraction_path = Rails.root.join("tmp", "ZipReaderExtractionPath")
        FileUtils.mkdir_p @root_extraction_path
        super
      end

      private

        def perform_read
          # read zip file
          source_file = Zip::File.open(@source_location)
          # find files with extension zip
          pbcore_xml_documents = source_file.glob('*.xml')
          # raise exception if there are no xml files in zip
          raise Hyrax::BatchIngest::ReaderError, I18n.t('hyrax.batch_ingest.readers.errors.invalid_batch_item_file_type', source_location: source_location) if pbcore_xml_documents.to_a.blank?
          # initialize batch items
          @batch_items = []
          # create random dir in output dir
          create_output_dir
          # Open each xml file, validate pbcore schema and add in batch items
          pbcore_xml_documents.each_with_index do |f,index|
            # TODO: findout why export is not validating
            #validate pbcore xml
            # schema = Nokogiri::XML::Schema(File.read(Rails.root.join('spec', 'fixtures', 'pbcore-2.1.xsd')))
            # document = Nokogiri::XML(f.get_input_stream.read)
            # schema.validate(document).each do |error|
            #   raise Hyrax::BatchIngest::ReaderError, I18n.t('hyrax.batch_ingest.readers.errors.invalid_btach_item_pbcoredocument', file_name_in_zip: f.name)
            # end
            # calculate file path where to extract
            f_path=File.join(@extraction_path, f.name)
            # extract valid file from zip
            source_file.extract(f, f_path)
            # Add item in zip file
            @batch_items <<  Hyrax::BatchIngest::BatchItem.new(id_within_batch: File.basename(f.name, ".*"),
                                                               source_location: f_path, status: :initialized)
          end
        rescue StandardError
          raise Hyrax::BatchIngest::ReaderError, I18n.t('hyrax.batch_ingest.readers.errors.invalid_source_location', source_location: source_location)
        ensure
          source_file.close if source_file
        end

        def create_output_dir
          @extraction_path = File.expand_path "#{@root_extraction_path}/#{Time.now.to_i}#{rand(1000)}/"
          FileUtils.mkdir_p @extraction_path
        end
    end
  end
end
