module AAPB
  module BatchIngest
    class PBCoreXMLMapper

      attr_reader :pbcore_xml

      def initialize(pbcore_xml)
        @pbcore_xml = pbcore_xml
      end

      def asset_attributes
        @asset_attributes ||= {}.tap do |attrs|
          # Saves Asset with AAPB ID if present

          annotations, admindata = separate_admindata(pbcore.annotations)

          # bring along the ol' admin data, to be removed in the actor
          attrs[:level_of_user_access] = admindata.select {|anno| anno.type }.map(&:value)
          attrs[:minimally_cataloged] = admindata.select {|anno| anno.type }.map(&:value)
          attrs[:outside_url] = admindata.select {|anno| anno.type }.map(&:value)
          attrs[:special_collection] = admindata.select {|anno| anno.type }.map(&:value)
          attrs[:transcript_status] = admindata.select {|anno| anno.type }.map(&:value)
          attrs[:sonyci_id] = admindata.select {|anno| anno.type }.map(&:value)
          attrs[:licensing_info] = admindata.select {|anno| anno.type }.map(&:value)
          attrs[:created_at] = admindata.select {|anno| anno.type }.map(&:value)
          attrs[:updated_at] = admindata.select {|anno| anno.type }.map(&:value)
          attrs[:playlist_group] = admindata.select {|anno| anno.type }.map(&:value)
          attrs[:playlist_order] = admindata.select {|anno| anno.type }.map(&:value)


          attrs[:id]                          = normalized_aapb_id(aapb_id) if aapb_id
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
          attrs[:annotation]                  = annotations.map(&:value)
          attrs[:rights_summary]              = pbcore.rights_summaries.map(&:rights_summary).compact.map(&:value)
          attrs[:rights_link]                 = pbcore.rights_summaries.map(&:rights_link).compact.map(&:value)
          attrs[:local_identifier]            = pbcore.identifiers.select { |identifier| identifier.source.to_s.downcase == "local identifier" }.map(&:value)
          attrs[:pbs_nola_code]               = pbcore.identifiers.select { |identifier| ['nola code', 'nola'].include? identifier.source.to_s.downcase }.map(&:value)
          attrs[:eidr_id]                     = pbcore.identifiers.select { |identifier| identifier.source.to_s.downcase == "eidr" }.map(&:value)
          attrs[:sonyci_id]                   = pbcore.identifiers.select { |identifier| identifier.source.to_s.downcase == "sony ci" }.map(&:value)
          attrs[:topics]                      = pbcore.genres.select { |genre| genre.source.to_s.downcase == "aapb topical genre" }.map(&:value)
          attrs[:subject]                     = pbcore.subjects.map(&:value)
          attrs[:contributors]                = contributor_attributes(pbcore.contributors)
        end
      end

      def separate_admindata(annotations)
        require('pry');binding.pry
        annotations.partition {|anno| ["Level of User Access","Cataloging Status","Outside URL","special_collections","Transcript Status","Licensing Info","Playlist Group","Playlist Order"].exclude?(anno.type) }
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
          @title_types ||= ['program', 'episode', 'episode title', 'episode number', 'segment', 'clip', 'promo', 'raw footage']
        end
    end
  end
end
