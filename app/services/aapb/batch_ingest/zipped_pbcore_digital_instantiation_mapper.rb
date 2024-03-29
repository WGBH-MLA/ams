require 'roo'

module AAPB
  module BatchIngest
    class ZippedPBCoreDigitalInstantiationMapper

      EXPECTED_HEADERS = [
        "DigitalInstantiation.filename",
        "Asset.id",
        "DigitalInstantiation.generations",
        "DigitalInstantiation.holding_organization",
        "DigitalInstantiation.aapb_preservation_lto",
        "DigitalInstantiation.aapb_preservation_disk",
        "DigitalInstantiation.md5"
      ]

      attr_reader :batch_item, :pbcore

      def initialize(batch_item)
        @batch_item = batch_item
        @file = batch_item.id_within_batch
        @workbook = Roo::Spreadsheet.open(batch_item.source_location)
        @workbook.default_sheet = @workbook.sheets[0]
        @workbook_headers = @workbook.row(1).map(&:strip)
        verify_headers
      end

      def digital_instantiation_attributes
        @instantiation_attributes ||= {}.tap do |attrs|
          # DigitalInstantiationActor will handle the PBCore
          attrs[:pbcore_xml]                      = batch_item.source_data

          # manifest attributes
          attrs[:title]                           = parent_asset.title
          attrs[:generations]                     = row_data[:generations] unless row_data[:generations].nil?
          attrs[:holding_organization]            = row_data[:holding_organization][0]unless row_data[:holding_organization].nil?
          attrs[:aapb_preservation_lto]           = row_data[:aapb_preservation_lto][0] unless row_data[:aapb_preservation_lto].nil?
          attrs[:aapb_preservation_disk]          = row_data[:aapb_preservation_disk][0] unless row_data[:aapb_preservation_disk].nil?
          attrs[:md5]                             = row_data[:md5][0] unless row_data[:md5].nil?
        end
      end

      def parent_asset
        @asset ||= Hyrax.query_service.find_by(id: row_data[:id].first)
      end

      private

        def pbcore
          @pbcore ||= case
                      when is_instantiation_document?
                        PBCore::InstantiationDocument.parse(batch_item.source_data)
                      when is_instantiation?
                        PBCore::Instantiation.parse(batch_item.source_data)
                        # TODO: Custom error class?
                      else
                        raise "XML not recognized as DigitalInstantiationPBCore"
                      end
        end

        def is_instantiation_document?
          batch_item.source_data =~ /pbcoreInstantiationDocument/
        end

        def is_instantiation?
          batch_item.source_data =~ /pbcoreInstantiation/
        end

        def row_data
          @row_data ||= begin
            # + 1 because Roo rows are not zero indexed
            row_num = @workbook.column(1).find_index(batch_item.id_within_batch) + 1
            row_values = @workbook.row(row_num).map(&:to_s)
            row_hash = {}.compare_by_identity
            @workbook_headers.each_with_index do |header, index|
              header = header.split('.')[1].to_sym
              row_hash[header] = [] unless row_hash.keys.include?(header)
              row_hash[header] << row_values[index]
            end
            row_hash
          end
        end

        def verify_headers
          raise "DigitalInstantiation.filename must be in the first column" unless @workbook_headers[0] == "DigitalInstantiation.filename"
          @workbook_headers.each do |header|
            raise "Unexpected Manifest header \"#{header}\" in #{batch_item.source_location}. Expected headers are: #{EXPECTED_HEADERS}." unless EXPECTED_HEADERS.include?(header)
          end
        end
    end
  end
end
