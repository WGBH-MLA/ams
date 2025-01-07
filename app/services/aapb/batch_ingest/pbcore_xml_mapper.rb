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

      def prepare_annotations(annotations)
        final_annotations = []

        annotations.each do |anno|
          annotation_type = find_annotation_type_id(anno.type)

          anno_hash = {
            "ref" => anno.ref,
            "annotation_type" => annotation_type,
            "source" => anno.source,
            "value" => anno.value,
            "annotation" => anno.annotation,
            "version" => anno.version
          }

          final_annotations << anno_hash
        end
        final_annotations
      end

      def find_annotation_type_id(type)
        type_id = Annotation.find_annotation_type_id(type)

        if ENV['SETTINGS__BULKRAX__ENABLED'] == 'true'
          type_id
        else
          if type_id.present?
            type_id
          else
            raise "annotation_type not registered with the AnnotationTypesService: #{type}."
          end
        end
      end

      def asset_attributes
        @asset_attributes ||= {}.tap do |attrs|

          attrs[:annotations]                 = prepare_annotations(pbcore.annotations)

          # Saves Asset with AAPB ID if present
          attrs[:id]                          = normalized_aapb_id(aapb_id) if aapb_id

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
          attrs[:series_title]                = grouped_titles["series"] if grouped_titles["series"]
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

          grouped_dates = categorize(pbcore.asset_dates)
          # pull out no-type dates, removing from grouped_dates
          dates_no_type = grouped_dates.slice!(*date_types)
          attrs[:date]                        = transform_dates dates_no_type.values.flatten
          attrs[:broadcast_date]              = transform_dates grouped_dates.fetch("broadcast", [])
          attrs[:copyright_date]              = transform_dates grouped_dates.fetch("copyright", [])
          attrs[:created_date]                = transform_dates grouped_dates.fetch("created", [])

          attrs[:audience_level]              = pbcore.audience_levels.map(&:value)
          attrs[:audience_rating]             = pbcore.audience_ratings.map(&:value)
          attrs[:asset_types]                 = pbcore.asset_types.map(&:value)
          attrs[:genre]                       = pbcore.genres.select { |genre| genre.source.to_s.downcase == "aapb format genre" }.map(&:value)
          attrs[:topics]                      = pbcore.genres.select { |genre| genre.source.to_s.downcase == "aapb topical genre" }.map(&:value)

          grouped_coverages = categorize(pbcore.coverages, criteria: [:type,:value,:downcase,:strip], accessor: [:coverage, :value])
          attrs[:spatial_coverage]            = grouped_coverages["spatial"] if grouped_coverages["spatial"]
          attrs[:temporal_coverage]           = grouped_coverages["temporal"] if grouped_coverages["temporal"]

          attrs[:rights_summary]              = pbcore.rights_summaries.map(&:summary).compact.map(&:value)
          attrs[:rights_link]                 = pbcore.rights_summaries.map(&:link).compact.map(&:value)

          grouped_identifiers = categorize(pbcore.identifiers, criteria: [:source,:to_s,:downcase])
          # pull out identifiers with an unknown source and add as local identifiers
          other_identifiers                   = grouped_identifiers.slice!(*identifier_sources)
          attrs[:local_identifier]            = (grouped_identifiers.fetch("local identifier", []) + other_identifiers.values).flatten
          attrs[:pbs_nola_code]               = (grouped_identifiers.fetch("nola code", []) + grouped_identifiers.fetch("nola", []))
          attrs[:eidr_id]                     = grouped_identifiers["eidr"] if grouped_identifiers["eidr"]
          attrs[:sonyci_id]                   = grouped_identifiers["sony ci"] if grouped_identifiers["sony ci"]

          attrs[:subject]                     = pbcore.subjects.map(&:value)

          creator_orgs, creator_people        = pbcore.creators.partition { |pbcreator| pbcreator.role&.value == 'Producing Organization' }
          all_people = pbcore.contributors + pbcore.publishers + creator_people
          attrs[:contributors]                = people_attributes(all_people)
          attrs[:producing_organization]      = creator_orgs.map {|co| co.creator.value}

          intended_children_count = 0
          intended_children_count += pbcore.instantiations.size
          intended_children_count += pbcore.instantiations.map(&:essence_tracks).flatten.size
          attrs[:intended_children_count]     = intended_children_count
        end
      end

      def aapb_id
        @aapb_id ||= pbcore.identifiers.select do |id|
          id.source == "http://americanarchiveinventory.org"
        end.map(&:value).first
      end

      def normalized_aapb_id(id)
        id.gsub('cpb-aacip/', 'cpb-aacip-') if id
      end

      def people_attributes(people)
        people.map do |person_node|
          person = if person_node.is_a? PBCore::Contributor
            person_node.contributor
          elsif person_node.is_a? PBCore::Publisher
            person_node.publisher
          elsif person_node.is_a? PBCore::Creator
            person_node.creator
          end

          role = person_node.role
          person_attributes(person, role)
        end
      end

      def person_attributes(person, role)
        {
          contributor: (person.value if person),
          contributor_role: (role.value if role),
          # pbcorecontributor ONLY
          affiliation: (person.affiliation if defined? person.affiliation),
          portrayal: (role.portrayal if role && defined? role.portrayal),
        }

      end

      def physical_instantiation_resource_attributes
        @physical_instantiation_resource_attributes ||= instantiation_attributes.tap do |attrs|
          attrs[:format] = pbcore.physical.value || nil
        end
      end

      def digital_instantiation_resource_attributes
        @digital_instantiation_attributes ||= instantiation_attributes.tap do |attrs|
          attrs[:format] = pbcore.digital.value || nil
        end
      end

      def instantiation_attributes
        @instantiation_attributes ||= {}.tap do |attrs|
          attrs[:date]                            = transform_dates(pbcore.dates.select { |date| date.type.to_s.downcase.strip != "digitized" }.map(&:value))
          attrs[:digitization_date]               = transform_dates(pbcore.dates.select { |date| date.type.to_s.downcase.strip == "digitized" }.map(&:value).first)

          attrs[:dimensions]                      = pbcore.dimensions.map(&:value)
          attrs[:standard]                        = pbcore.standard&.value
          attrs[:location]                        = pbcore.location&.value
          attrs[:media_type]                      = pbcore.media_type&.value
          attrs[:format]                          = pbcore.physical&.value
          attrs[:generations]                     = pbcore.generations.map(&:value)
          attrs[:time_start]                      = pbcore.time_start&.value
          attrs[:duration]                        = pbcore.duration&.value&.gsub('?', '')
          attrs[:colors]                          = pbcore.colors&.value

          # TODO: change left side to rights_summaries (because multiple: true), or to rights (to agree with PBCore gem's Instantiation#rights)
          attrs[:rights_summary]                  = pbcore.rights.map(&:summary).map(&:value)
          attrs[:rights_link]                     = pbcore.rights.map(&:link).map(&:value)
          attrs[:local_instantiation_identifier]  = pbcore.identifiers.select { |identifier| identifier.source.to_s.downcase.strip != "ams" }.map(&:value)
          attrs[:tracks]                          = pbcore.tracks&.value
          attrs[:channel_configuration]           = pbcore.channel_configuration&.value
          attrs[:alternative_modes]               = pbcore.alternative_modes&.value

          orgs, annotations = pbcore.annotations.partition { |anno| anno.type && anno.type.downcase == 'organization' }
          attrs[:holding_organization] = orgs.first.value if orgs.present?
          attrs[:annotation] = annotations.map(&:value)
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
          attrs[:sample_rate] = pbcore.sampling_rate.value if pbcore.sampling_rate
          attrs[:bit_depth] = pbcore.bit_depth.value if pbcore.bit_depth

          # frame size becomes:
          frame_width, frame_height = pbcore.frame_size.value.split('x') if pbcore.frame_size
          attrs[:frame_width] = frame_width
          attrs[:frame_height] = frame_height
          attrs[:aspect_ratio] = pbcore.aspect_ratio.value if pbcore.aspect_ratio
          attrs[:time_start] = pbcore.time_start.value if pbcore.time_start
          attrs[:duration] = pbcore.duration.value.gsub('?', '') if pbcore.duration
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
          @desc_types ||= ['program','segment','clip','promo','footage','episode','series','raw footage','program description','segment description','clip description','promo description','raw footage description','episode description','series description']
        end

        def date_types
          @date_types ||= ['broadcast', 'copyright', 'created']
        end

        def identifier_sources
          @identifier_sources ||= ['nola code','local identifier','eidr','sony ci', 'http://americanarchiveinventory.org']
        end

        # Transforms one or more dates.
        # @param [Array<String>, String] dates a date string, or an array of
        #  date strings to sanitize.
        # @return [Array<String>, String, nil]
        #  If a single date was passed in, returns sanitized date, or nil.
        #  If multiple dates were passed in, returns array of sanitized dates
        #  with nils removed.
        def transform_dates(dates)
          if dates.respond_to?(:map)
            dates.map { |date| transform_date(date) }.compact
          else
            transform_date dates
          end
        end

        # Transforms some known invalid dates into acceptable date formats.
        # @param [String] date a date string.
        # @return [String, Nil] if the date param matches a known invalid format
        #  it will return the transoformed date; otherwise returns date param
        #  as-is so that other invalid dates of unknown format show up in the
        #  error message.
        def transform_date(date)
          case date
          when /0000\-00\-00/
            nil
          when /\-00/
            date.gsub(/-00/, '')
          else
            date
          end
        end
    end
  end
end
