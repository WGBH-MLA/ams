module WGBH
  module BatchIngest
    class PBCoreXMLMapper

      attr_reader :pbcore_xml

      def initialize(pbcore_xml)
        @pbcore_xml = pbcore_xml
      end

      def asset_attributes
        @asset_attributes ||= {}.tap do |attrs|
          attrs[:title]                       = pbcore.titles.select { |title| title_types.none? { |t| t == title.type.to_s.downcase.strip } }.map(&:value)
          attrs[:program_title]               = pbcore.titles.select { |title| title.type.to_s.downcase.strip == "program" }.map(&:value)
          attrs[:episode_title]               = pbcore.titles.select { |title| ["episode", "episode title"].include? title.type.to_s.downcase.strip }.map(&:value)
          attrs[:segment_title]               = pbcore.titles.select { |title| title.type.to_s.downcase.strip == "segment" }.map(&:value)
          attrs[:clip_title]                  = pbcore.titles.select { |title| title.type.to_s.downcase.strip == "clip" }.map(&:value)
          attrs[:promo_title]                 = pbcore.titles.select { |title| title.type.to_s.downcase.strip == "promo" }.map(&:value)
          attrs[:raw_footage_title]           = pbcore.titles.select { |title| title.type.to_s.downcase.strip == "raw footage" }.map(&:value)
          attrs[:episode_number]              = pbcore.titles.select { |title| title.type.to_s.downcase.strip == "episode number" }.map(&:value)
          attrs[:description]                 = pbcore.descriptions.select { |description| description.type.nil? }.map(&:value)
          attrs[:program_description]         = pbcore.descriptions.select { |description| description.type.to_s.downcase.strip == "program" }.map(&:value)
          attrs[:episode_description]         = pbcore.descriptions.select { |description| ["episode", "episode description"].include? description.type.to_s.downcase.strip }.map(&:value)
          attrs[:segment_description]         = pbcore.descriptions.select { |description| description.type.to_s.downcase.strip == "segment" }.map(&:value)
          attrs[:clip_description]            = pbcore.descriptions.select { |description| description.type.to_s.downcase.strip == "clip" }.map(&:value)
          attrs[:promo_description]           = pbcore.descriptions.select { |description| description.type.to_s.downcase.strip == "promo" }.map(&:value)
          attrs[:raw_footage_description]     = pbcore.descriptions.select { |description| description.type.to_s.downcase.strip == "raw footage" }.map(&:value)
          attrs[:audience_level]              = pbcore.audience_levels.map(&:value)
          attrs[:audience_rating]             = pbcore.audience_ratings.map(&:value)
          attrs[:asset_types]                 = pbcore.asset_types.map(&:value)
          attrs[:genre]                       = pbcore.genres.map(&:value)
          attrs[:spatial_coverage]            = pbcore.coverages.select { |coverage| coverage.type.value.downcase.strip == "spatial" }.map { |coverage| coverage.coverage.value }
          attrs[:temporal_coverage]           = pbcore.coverages.select { |coverage| coverage.type.value.downcase.strip == "temporal" }.map { |coverage| coverage.coverage.value }
          attrs[:annotation]                  = pbcore.annotations.map(&:value)
          attrs[:rights_summary]              = pbcore.rights_summaries.map(&:rights_summary).compact.map(&:value)
          attrs[:rights_link]                 = pbcore.rights_summaries.map(&:rights_link).compact.map(&:value)
          attrs[:local_identifier]            = pbcore.identifiers.select { |identifier| identifier.source.to_s.downcase == "local identifier" }.map(&:value)
          attrs[:pbs_nola_code]               = pbcore.identifiers.select { |identifier| ['nola code', 'nola'].include? identifier.source.to_s.downcase }.map(&:value)
          attrs[:eidr_id]                     = pbcore.identifiers.select { |identifier| identifier.source.to_s.downcase == "eidr" }.map(&:value)
          attrs[:topics]                      = pbcore.genres.select { |genre| genre.source.to_s.downcase == "aapb topical genre" }.map(&:value)
          attrs[:subject]                     = pbcore.subjects.map(&:value)
        end
      end

      def physical_instantiation_attributes
        @physical_instantiation_attributes ||= {}.tap do |attrs|
          attrs[:date]                            = pbcore.dates.select { |date| date.type.to_s.downcase.strip != "digitized" }.map(&:value)
          attrs[:digitization_date]               = pbcore.dates.select { |date| date.type.to_s.downcase.strip == "digitized" }.first.value
          attrs[:dimensions]                      = pbcore.dimensions.map(&:value)
          attrs[:standard]                        = pbcore.standard.value || nil
          attrs[:format]                          = pbcore.physical.value || nil
          attrs[:location]                        = pbcore.location.value || nil
          attrs[:media_type]                      = pbcore.media_type.value || nil
          attrs[:generations]                     = pbcore.generations.map(&:value)
          attrs[:time_start]                      = pbcore.time_starts.map(&:value)
          attrs[:duration]                        = pbcore.duration.value || nil
          attrs[:colors]                          = pbcore.colors.value || nil
          attrs[:instantiation_rights_summary]    = pbcore.rights.map(&:rights_summary).map(&:value)
          attrs[:instantiation_rights_link]       = pbcore.rights.map(&:rights_link).map(&:value)
          attrs[:local_instantiation_identifier]  = pbcore.identifiers.select { |identifier| identifier.source.to_s.downcase.strip != "ams" }.map(&:value)
          attrs[:tracks]                          = pbcore.tracks.value || nil
          attrs[:channel_configuration]           = pbcore.channel_configuration.value || nil
          attrs[:alternative_modes]               = pbcore.alternative_modes.value || nil
        end
      end

      private

        def pbcore
          @pbcore ||= case
                      when is_description_document?
                        PBCore::DescriptionDocument.parse(pbcore_xml)
                      when is_instantiation_document?
                        PBCore::InstantiationDocument.parse(pbcore_xml)
                      when is_collection?
                        # TODO: Custom error class?
                        raise "pbcoreCollection not yet supported"
                      else
                        # TODO: Custom error class?
                        raise "XML not recognized as PBCore"
                      end
        end

        def is_description_document?
          pbcore_xml =~ /pbcoreDescriptionDocument/
        end

        def is_instantiation_document?
          pbcore_xml =~ /pbcoreInstantiationDocument/
        end

        def title_types
          @title_types ||= ['program', 'episode', 'episode title', 'episode number', 'segment', 'clip', 'promo', 'raw footage']
        end
    end
  end
end
