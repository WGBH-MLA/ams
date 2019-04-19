module AAPB
  module BatchIngest
    class PBCoreXMLMapper

      attr_reader :pbcore_xml

      def initialize(pbcore_xml)
        @pbcore_xml = pbcore_xml
      end

      def categorize(collection, criteria: [:type,:to_s,:downcase,:strip], accessor: [:value])
        grouped = {}
        collection.each do |anno|
          cat_name = criteria.inject(anno) {|object, method| object.send(method) }
          value = accessor.inject(anno) {|object, method| object.send(method) }

          if value
            grouped[ cat_name ] ||= []
            grouped[ cat_name ] << value
          end
        end
        grouped
      end

      def admindata_field_names
        @admindata_field_names ||= ["level of user access", "cataloging status", "outside url", "special_collections", "transcript status", "licensing info", "playlist group", "playlist order"]
      end

      def asset_attributes
        @asset_attributes ||= {}.tap do |attrs|
          annotations, admindata = separate_admindata(pbcore.annotations)

          # bring along the ol' admin data, to be removed in the actor
          admindata_field_names.each do |field_name|
            field_name = 'minimally_cataloged' if field_name == 'cataloging status'
            field_name = 'special_collection' if field_name == 'special_collections'
            attrs[:"#{field_name.gsub(" ", '_')}"] = admindata[field_name] if admindata[field_name]
          end

          # Saves Asset with AAPB ID if present
          attrs[:id]                          = normalized_aapb_id(aapb_id) if aapb_id

          # map the non admindata annotations
          attrs[:annotation]                  = annotations

          # grouped by title type
          grouped_titles = categorize(pbcore.titles)
          # pull out no-type titles, removing from grouped_titles
          titles_no_type = grouped_titles.slice!(*title_types)
          attrs[:title]                       = titles_no_type.values.flatten
          attrs[:episode_title]               = grouped_titles["episode"] if grouped_titles["episode"]
          attrs[:program_title]               = grouped_titles["program"] if grouped_titles["program"]
          attrs[:segment_title]               = grouped_titles["segment"] if grouped_titles["segment"]
          attrs[:clip_title]                  = grouped_titles["clip"] if grouped_titles["clip"]
          attrs[:promo_title]                 = grouped_titles["promo"] if grouped_titles["promo"]
          attrs[:raw_footage_title]           = grouped_titles["raw footage"] if grouped_titles["raw footage"]
          attrs[:episode_number]              = grouped_titles["episode number"] if grouped_titles["episode number"]

          grouped_descriptions = categorize(pbcore.descriptions)
          # pull out no-type descs, removing from grouped_descs
          descriptions_no_type = grouped_descriptions.slice!(*desc_types)
          attrs[:description]                 = descriptions_no_type.values.flatten
          attrs[:episode_description]         = (grouped_descriptions.fetch("episode", []) + grouped_descriptions.fetch("episode description", []))
          attrs[:series_description]          = (grouped_descriptions.fetch("series", []) + grouped_descriptions.fetch("series description", []))
          attrs[:program_description]         = (grouped_descriptions.fetch("program", []) + grouped_descriptions.fetch("program description", []))
          attrs[:segment_description]         = (grouped_descriptions.fetch("segment", []) + grouped_descriptions.fetch("segment description", []))
          attrs[:clip_description]            = (grouped_descriptions.fetch("clip", []) + grouped_descriptions.fetch("clip description", []))
          attrs[:promo_description]           = (grouped_descriptions.fetch("promo", []) + grouped_descriptions.fetch("promo description", []))
          attrs[:raw_footage_description]     = (grouped_descriptions.fetch("raw footage", []) + grouped_descriptions.fetch("raw footage description", []))
          # attrs[:episode_description]         = grouped_descriptions["episode description"] if grouped_descriptions["episode description"]
          # attrs[:series_description]          = grouped_descriptions["series description"] if grouped_descriptions["series description"]
          # attrs[:program_description]         = grouped_descriptions["program description"] if grouped_descriptions["program description"]
          # attrs[:segment_description]         = grouped_descriptions["segment description"] if grouped_descriptions["segment description"]
          # attrs[:clip_description]            = grouped_descriptions["clip description"] if grouped_descriptions["clip description"]
          # attrs[:promo_description]           = grouped_descriptions["promo description"] if grouped_descriptions["promo description"]
          # attrs[:raw_footage_description]     = grouped_descriptions["raw footage description"] if grouped_descriptions["raw footage description"]

          attrs[:audience_level]              = pbcore.audience_levels.map(&:value)
          attrs[:audience_rating]             = pbcore.audience_ratings.map(&:value)
          attrs[:asset_types]                 = pbcore.asset_types.map(&:value)
          attrs[:genre]                       = pbcore.genres.map(&:value)
          attrs[:topics]                      = pbcore.genres.select { |genre| genre.source.to_s.downcase == "aapb topical genre" }.map(&:value)

          grouped_coverages = categorize(pbcore.coverages, criteria: [:type,:value,:downcase,:strip], accessor: [:coverage, :value])
          attrs[:spatial_coverage]            = grouped_coverages["spatial"] if grouped_coverages["spatial"]
          attrs[:temporal_coverage]           = grouped_coverages["temporal"] if grouped_coverages["temporal"]

          attrs[:rights_summary]              = pbcore.rights_summaries.map(&:rights_summary).compact.map(&:value)
          attrs[:rights_link]                 = pbcore.rights_summaries.map(&:rights_link).compact.map(&:value)

          grouped_identifiers = categorize(pbcore.identifiers, criteria: [:source,:to_s,:downcase])
          attrs[:pbs_nola_code]               = (grouped_identifiers.fetch("nola code", []) + grouped_identifiers.fetch("nola", []))
          attrs[:local_identifier]            = grouped_identifiers["local identifier"] if grouped_identifiers["local identifier"]
          attrs[:eidr_id]                     = grouped_identifiers["eidr"] if grouped_identifiers["eidr"]
          attrs[:sonyci_id]                   = grouped_identifiers["sony ci"] if grouped_identifiers["sony ci"]

          attrs[:subject]                     = pbcore.subjects.map(&:value)
          attrs[:contributors]                = contributor_attributes(pbcore.contributors)
        end
      end

      def separate_admindata(all_annotations)
        annotations = categorize(all_annotations)
        no_type = annotations[""]
        admindata = annotations.except("")
        return [no_type, admindata]
      end

      def aapb_id
        @aapb_id ||= pbcore.identifiers.select { |id|
            id.source == "http://americanarchiveinventory.org"}.map(&:value).first
      end

      def normalized_aapb_id(id)
        id.gsub('cpb-aacip/', 'cpb-aacip_') if id
      end

      def contributor_attributes(contributors)
        contributors.map do |contributor_node|
          {
            contributor: (contributor_node.contributor.value if contributor_node.contributor),
            contributor_role: (contributor_node.role.value if contributor_node.role),
            affiliation: (contributor_node.contributor.affiliation if contributor_node.contributor),
            portrayal: (contributor_node.role.portrayal if contributor_node.role),
          }
        end
      end

      def physical_instantiation_attributes
        @physical_instantiation_attributes ||= instantiation_attributes.tap do |attrs|
          attrs[:format] = pbcore.physical.value || nil
        end
      end

      def digital_instantiation_attributes
        @digital_instantiation_attributes ||= instantiation_attributes.tap do |attrs|
          attrs[:format] = pbcore.digital.value || nil
        end
      end

      def instantiation_attributes
        @instantiation_attributes ||= {}.tap do |attrs|
          attrs[:date]                            = pbcore.dates.select { |date| date.type.to_s.downcase.strip != "digitized" }.map(&:value)
          attrs[:digitization_date]               = pbcore.dates.select { |date| date.type.to_s.downcase.strip == "digitized" }.map(&:value).first
          attrs[:dimensions]                      = pbcore.dimensions.map(&:value)
          attrs[:standard]                        = pbcore.standard&.value
          attrs[:location]                        = pbcore.location&.value
          attrs[:media_type]                      = pbcore.media_type&.value
          attrs[:format]                          = pbcore.physical&.value
          attrs[:generations]                     = pbcore.generations.map(&:value)
          attrs[:time_start]                      = pbcore.time_starts.map(&:value)
          attrs[:duration]                        = pbcore.duration&.value
          attrs[:colors]                          = pbcore.colors&.value
          attrs[:rights_summary]                  = pbcore.rights.map(&:rights_summary).map(&:value)
          attrs[:rights_link]                     = pbcore.rights.map(&:rights_link).map(&:value)
          attrs[:local_instantiation_identifier]  = pbcore.identifiers.select { |identifier| identifier.source.to_s.downcase.strip != "ams" }.map(&:value)
          attrs[:tracks]                          = pbcore.tracks&.value
          attrs[:channel_configuration]           = pbcore.channel_configuration&.value
          attrs[:alternative_modes]               = pbcore.alternative_modes&.value
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
                      when is_description_document?
                        PBCore::DescriptionDocument.parse(pbcore_xml)
                      when is_instantiation_document?
                        PBCore::InstantiationDocument.parse(pbcore_xml)
                      when is_instantiation?
                        PBCore::Instantiation.parse(pbcore_xml)
                      when is_essence_track?
                        PBCore::Instantiation::EssenceTrack.parse(pbcore_xml)
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

        def is_instantiation?
          pbcore_xml =~ /pbcoreInstantiation/
        end

        def is_essence_track?
          pbcore_xml =~ /instantiationEssenceTrack/
        end

        def title_types
          @title_types ||= ['program', 'episode', 'episode title', 'episode number', 'segment', 'clip', 'promo', 'raw footage', 'series']
        end

        def desc_types
          @desc_types ||= ["program","segment","clip","promo","raw footage","episode","series","program description","segment description","clip description","promo description","raw footage description","episode description","series description",]
        end
    end
  end
end
