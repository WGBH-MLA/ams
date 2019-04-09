require 'roo'

module AAPB
  module BatchIngest
    class ZippedPBCoreDigitalInstantiationMapper

      EXPECTED_HEADERS = [
        "DigitalInstantiation.filename",
        "Asset.id",
        "DigitalInstantiation.generations",
        "DigitalInstantiation.location",
        "DigitalInstantition.aapb_preservation_lto",
        "DigitalInstantition.aapb_preservation_disk"
      ]

      attr_reader :batch_item, :pbcore, :row_data

      def initialize(batch_item)
        @batch_item = batch_item
        @file = batch_item.id_within_batch
        @workbook = Roo::Spreadsheet.open(batch_item.source_location)
        @workbook.default_sheet = @workbook.sheets[0]
        @workbook_headers = @workbook.row(1).map(&:strip)
        verify_headers
        # Construct hash of row data from the spreadsheet
        @row_data = get_row_data
      end

      def digital_instantiation_attributes
        @digital_instantiation_attributes ||= digital_instantiation_attributes
      end

      def digital_instantiation_attributes
        @instantiation_attributes ||= {}.tap do |attrs|
          # pbcore attributes
          attrs[:date]                            = pbcore.dates.select { |date| date.type.to_s.downcase.strip != "digitized" }.map(&:value)
          attrs[:digitization_date]               = pbcore.dates.select { |date| date.type.to_s.downcase.strip == "digitized" }.map(&:value).first
          attrs[:dimensions]                      = pbcore.dimensions.map(&:value)
          attrs[:standard]                        = pbcore.standard&.value
          attrs[:location]                        = pbcore.location&.value
          attrs[:media_type]                      = pbcore.media_type&.value
          attrs[:format]                          = pbcore.physical&.value
          attrs[:time_start]                      = pbcore.time_starts.map(&:value)
          attrs[:duration]                        = pbcore.duration&.value
          attrs[:colors]                          = pbcore.colors&.value
          attrs[:rights_summary]                  = pbcore.rights.map(&:rights_summary).map(&:value)
          attrs[:rights_link]                     = pbcore.rights.map(&:rights_link).map(&:value)
          attrs[:local_instantiation_identifier]  = pbcore.identifiers.select { |identifier| identifier.source.to_s.downcase.strip != "ams" }.map(&:value)
          attrs[:tracks]                          = pbcore.tracks&.value
          attrs[:channel_configuration]           = pbcore.channel_configuration&.value
          attrs[:alternative_modes]               = pbcore.alternative_modes&.value
          attrs[:format]                          = pbcore.digital.value || nil

          # manifest attributes
          attrs[:generations]                     = row_data[:generations] unless row_data[:generations].nil?
          attrs[:location]                        = row_data[:location][0] unless row_data[:location].nil?
          attrs[:aapb_preservation_lto]           = row_data[:aapb_preservation_lto][0] unless row_data[:aapb_preservation_lto].nil?
          attrs[:aapb_preservation_disk]          = row_data[:aapb_preservation_disk][0] unless row_data[:aapb_preservation_disk].nil?
        end
      end

      def essence_track_attributes
        @essence_track_attributes ||= {}.tap do |attrs|

          attrs[:track_type] = pbcore.type.value if pbcore.type
          attrs[:track_id] = pbcore.identifiers.map(&:value) if pbcore.identifiers
          attrs[:standard] = pbcore.standard.value if pbcore.standard
          attrs[:encoding] = pbcore.encoding.value if pbcore.encoding
          attrs[:data_rate] = pbcore.data_rate.value if pbcore.data_rate
          attrs[:frame_rate] = pbcore.frame_rate.value if pbcore.frame_rate
          # attrs[:playback_inch_per_sec] = pbcore.playback_speed.value if pbcore.playback_speed
          # attrs[:playback_frame_per_sec] = pbcore.playback_speed.value if pbcore.playback_speed
          attrs[:sample_rate] = pbcore.sampling_rate.value if pbcore.sampling_rate
          attrs[:bit_depth] = pbcore.bit_depth.value if pbcore.bit_depth

          # frame size becomes:
          frame_width, frame_height = pbcore.frame_size.value.split('x') if pbcore.frame_size
          attrs[:frame_width] = frame_width
          attrs[:frame_height] = frame_height
          attrs[:aspect_ratio] = pbcore.aspect_ratio.value if pbcore.aspect_ratio
          attrs[:time_start] = pbcore.time_start.value if pbcore.time_start
          attrs[:duration] = pbcore.duration.value if pbcore.duration
          attrs[:annotation] = pbcore.annotations.map(&:value) if pbcore.annotations
        end
      end

      private

        def pbcore
          @pbcore ||= case
                      when is_instantiation_document?
                        PBCore::InstantiationDocument.parse(batch_item.source_data)
                      when is_instantiation?
                        PBCore::Instantiation.parse(batch_item.source_data)
                      when is_essence_track?
                        PBCore::Instantiation::EssenceTrack.parse(batch_item.source_data)
                      else
                        # TODO: Custom error class?
                        raise "XML not recognized as DigitalInstantiationPBCore"
                      end
        end

        def is_description_document?
          batch_item.source_data =~ /pbcoreDescriptionDocument/
        end

        def is_instantiation_document?
          batch_item.source_data =~ /pbcoreInstantiationDocument/
        end

        def is_instantiation?
          batch_item.source_data =~ /pbcoreInstantiation/
        end

        def is_essence_track?
          batch_item.source_data =~ /instantiationEssenceTrack/
        end

        def read_generations
        end

        def get_row_data
          # + 1 because Roo rows are not zero indexed
          row_num = @workbook.column(1).find_index(batch_item.id_within_batch) + 1
          row_data = @workbook.row(row_num).map(&:to_s)
          row_hash = {}.compare_by_identity
          @workbook_headers.each_with_index do |header, index|
            header = header.split('.')[1].to_sym
            row_hash[header] = [] unless row_hash.keys.include?(header)
            row_hash[header] << row_data[index]
          end
          row_hash
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
