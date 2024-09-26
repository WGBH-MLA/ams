module PBCoreXPathHelper

  def pbcore_values_from_xpath(pbcore_xml, *xpaths)
    pbcore_xpath_helper(pbcore_xml).values_from_xpath(*xpaths)
  end

  def pbcore_xpath_helper(pbcore_xml)
    unless @pbcore_xpath_helper && @pbcore_xpath_helper.pbcore_xml == pbcore_xml
      @pbcore_xpath_helper = Helper.new(pbcore_xml)
    end
    @pbcore_xpath_helper
  end

  class Helper
    attr_reader :pbcore_xml
    def initialize(pbcore_xml)
      @pbcore_xml = pbcore_xml
    end

    def noko
      @noko ||= Nokogiri::XML(pbcore_xml).remove_namespaces!
    end

    def values_from_xpath(*xpaths)
      # Convert args that are symbols to the xpaths given in xpath_presets
      xpaths = xpaths.map do |xp|
        if xp.is_a? Symbol
          raise ArgumentError, "No xpath preset for :#{xp}" unless xpath_presets.key? xp
          xpath_presets[xp]
        else
          xp
        end
      end
      # Flatten xpaths to a 1-dimension array.
      # Map the xpath strings to the Nokogiri nodes found.
      # Filter out empty results.
      # Flatten again, to get a flat array of Nokogiri nodes.
      # Finally, map to #text (i.e. the value within the xml node).
      xpaths.flatten.map { |xp| noko.xpath(xp) }.select { |found| found.count > 0 }.flatten.map(&:text).map(&:strip)
    end

    def xpath_presets
      @xpath_presets ||= {
        series_title:                   '//pbcoreTitle[@titleType="Series"]',
        program_title:                  '//pbcoreTitle[@titleType="Program"]',
        episode_title:                  '//pbcoreTitle[@titleType="Episode" or @titleType="Episode Title"]',
        segment_title:                  '//pbcoreTitle[@titleType="Segment"]',
        clip_title:                     '//pbcoreTitle[@titleType="Clip"]',
        promo_title:                    '//pbcoreTitle[@titleType="Promo"]',
        raw_footage_title:              '//pbcoreTitle[@titleType="Raw Footage"]',
        episode_number:                 '//pbcoreTitle[@titleType="Episode Number"]',
        series_description:             '//pbcoreDescription[@descriptionType="Series"]',
        program_description:            '//pbcoreDescription[@descriptionType="Program"]',
        episode_description:            '//pbcoreDescription[@descriptionType="Episode" or @descriptionType="Episode Description"]',
        segment_description:            '//pbcoreDescription[@descriptionType="Segment"]',
        clip_description:               '//pbcoreDescription[@descriptionType="Clip"]',
        promo_description:              '//pbcoreDescription[@descriptionType="Promo"]',
        raw_footage_description:        '//pbcoreDescription[@descriptionType="Raw Footage"]',
        audience_level:                 '//pbcoreAudienceLevel',
        audience_rating:                '//pbcoreAudienceRating',
        asset_types:                    '//pbcoreAssetType',
        broadcast_date:                 '//pbcoreAssetDate[@dateType="Broadcast"]',
        copyright_date:                 '//pbcoreAssetDate[@dateType="Copyright"]',
        created_date:                   '//pbcoreAssetDate[@dateType="Created"]',
        genre:                          '//pbcoreGenre[@annotation="genre"]',
        level_of_user_access:           '//pbcoreAnnotation[@annotationType="Level of User Access"]',
        cataloging_status:              '//pbcoreAnnotation[@annotationType="cataloging status"]',
        outside_url:                    '//pbcoreAnnotation[@annotationType="Outside URL"]',
        special_collections:            '//pbcoreAnnotation[@annotationType="special_collections"]',
        transcript_status:              '//pbcoreAnnotation[@annotationType="Transcript Status"]',
        licensing_info:                 '//pbcoreAnnotation[@annotationType="Licensing Info"]',
        playlist_group:                 '//pbcoreAnnotation[@annotationType="Playlist Group"]',
        playlist_order:                 '//pbcoreAnnotation[@annotationType="Playlist Order"]',
        organization:                   '//pbcoreAnnotation[@annotationType="organization"]',
        canonical_meta_tag:             '//pbcoreAnnotation[@annotationType="Canonical Meta Tag"]',
        special_collection_category:    '//pbcoreAnnotation[@annotationType="Special Collection Category"]',
        captions_url:                   '//pbcoreAnnotation[@annotationType="Captions URL"]',
        external_reference_url:         '//pbcoreAnnotation[@annotationType="External Reference URL"]',
        last_modified:                  '//pbcoreAnnotation[@annotationType="last_modified"]',
        mavis_number:                   '//pbcoreAnnotation[@annotationType="MAVIS Number"]',
        project_code:                   '//pbcoreAnnotation[@annotationType="Project Code"]',
        supplemental_material:          '//pbcoreAnnotation[@annotationType="Supplemental Material"]',
        transcript_url:                 '//pbcoreAnnotation[@annotationType="Transcript URL"]',
        transcript_source:              '//pbcoreAnnotation[@annotationType="Transcript Source"]',
        proxy_start_time:               '//pbcoreAnnotation[@annotationType="Proxy Start Time"]',
        rights_summary:                 '//pbcoreRightsSummary/rightsSummary',
        rights_link:                    '//pbcoreRightsSummary/rightsLink',
        local_identifier:               '//pbcoreIdentifier[@source="Local Identifier"]',
        pbs_nola_code:                  '//pbcoreIdentifier[@source="NOLA Code"]',
        eidr_id:                        '//pbcoreIdentifier[@source="EIDR"]',
        sonyci_id:                      '//pbcoreIdentifier[@source="Sony Ci"]',
        topics:                         '//pbcoreGenre[@annotation="topic"]',
        subject:                        '//pbcoreSubject',
        digital_format:                 '//instantiationDigital',
        dimensions:                     '//instantiationDimensions',
        standard:                       '//instantiationStandard',
        generations:                    '//instantiationGenerations',
        time_start:                     '//instantiationTimeStart',
        local_instantiation_identifier: '//instantiationIdentifier',
        alternative_modes:              '//instantiationAlternativeModes',
        instantiation_rights_summary:   '//instantiationRights/rightsSummary',
        instantiation_rights_link:      '//instantiationRights/rightsLink',
        format:                         '//instantiationPhysical',
        location:                       '//instantiationLocation',
        media_type:                     '//instantiationMediaType',
        duration:                       '//instantiationDuration',
        colors:                         '//instantiationColors',
        tracks:                         '//instantiationTracks',
        channel_configuration:          '//instantiationChannelConfiguration',
        digitization_date:              '//instantiationDate[@dateType="Digitized"]',
        holding_organization:           '//instantiationAnnotation[@annotationType="organization"]',
        # Essence track xpath helper shortcuts
        ess_track_type:                 '//essenceTrackType',
        ess_track_id:                   '//essenceTrackIdentifier',
        ess_standard:                   '//essenceTrackStandard',
        ess_encoding:                   '//essenceTrackEncoding',
        ess_data_rate:                  '//essenceTrackDataRate',
        ess_frame_rate:                 '//essenceTrackFrameRate',
        ess_sample_rate:                '//essenceTrackSamplingRate',
        ess_bit_depth:                  '//essenceTrackBitDepth',
        ess_aspect_ratio:               '//essenceTrackAspectRatio',
        ess_duration:                   '//essenceTrackDuration',
        ess_annotations:                '//essenceTrackAnnotation',
        ess_time_start:                 '//essenceTrackTimeStart'
      }
    end


    # Shortcut method to pull out all titles that don't match the other title
    # types.
    # Usage: In your spec, do this..
    #   pbcore_xpath_helper(pbcore_xml).titles_without_type
    def titles_without_type
      all_titles = values_from_xpath('//pbcoreTitle')
      with_types = values_from_xpath(:series_title) + values_from_xpath(:program_title) + values_from_xpath(:episode_title) + values_from_xpath(:segment_title) + values_from_xpath(:clip_title) + values_from_xpath(:promo_title) + values_from_xpath(:raw_footage_title) + values_from_xpath(:episode_number)
      remove_exactly_once_from_array all_titles, with_types
    end

    # Shortcut method to pull out all descriptions that don't match the other description
    # types.
    # Usage: In your spec, do this..
    #   pbcore_xpath_helper(pbcore_xml).descriptions_without_type
    def descriptions_without_type
      all_descs = values_from_xpath('//pbcoreDescription')
      with_types = values_from_xpath(:series_description) + values_from_xpath(:program_description) + values_from_xpath(:episode_description) + values_from_xpath(:segment_description) + values_from_xpath(:clip_description) + values_from_xpath(:promo_description) + values_from_xpath(:raw_footage_description) + values_from_xpath(:episode_number)
      remove_exactly_once_from_array all_descs, with_types
    end

    # Shortcut method to pull out all asset dates that don't match the other
    # asset date types.
    # Usage: In your spec, do this..
    #   pbcore_xpath_helper(pbcore_xml).asset_dates_without_type
    def dates_without_type
      all_dates = values_from_xpath('//pbcoreAssetDate')
      with_types = values_from_xpath(:broadcast_date) + values_from_xpath(:copyright_date) + values_from_xpath(:created_date)
      remove_exactly_once_from_array all_dates, with_types
    end

    def spatial_coverage
      noko.xpath('//pbcoreCoverage').select{ |coverage| coverage.xpath('.//coverageType').text == "Spatial" }.map{ |e| e.xpath('.//coverage').text }
    end

    def temporal_coverage
      noko.xpath('//pbcoreCoverage').select{ |coverage| coverage.xpath('.//coverageType').text == "Temporal" }.map{ |e| e.xpath('.//coverage').text }
    end

    def producing_organization
      noko.xpath('//pbcoreCreator').select{ |creator| creator.xpath('.//creatorRole').text == "Producing Organization" }.map{ |e| e.xpath('.//creator').text }
    end

    # Since we're adding all Identifiers have an unmatched Source to the Asset's local_identifier property
    # we subtract all the known Identifiers to for checking in spec.
    def local_identifiers
      all_vals = values_from_xpath('//pbcoreIdentifier')
      other_types = values_from_xpath(:pbs_nola_code) +
                   values_from_xpath(:eidr_id) +
                   values_from_xpath(:sonyci_id) +
                   # Need ams_id in array
                   Array.new(1, ams_id)
      remove_exactly_once_from_array all_vals, other_types
    end

    # Shortcut method to pull out all annotations that don't match special
    # annotation types.
    # Usage: In your spec, do this..
    #   pbcore_xpath_helper(pbcore_xml).annotations_without_type
    def annotations_without_type
      all_vals = values_from_xpath('//pbcoreAnnotation')
      with_types = values_from_xpath(:level_of_user_access) +
                   values_from_xpath(:cataloging_status) +
                   values_from_xpath(:outside_url) +
                   values_from_xpath(:special_collections) +
                   values_from_xpath(:transcript_status) +
                   values_from_xpath(:proxy_start_time) +
                   values_from_xpath(:licensing_info) +
                   values_from_xpath(:playlist_group) +
                   values_from_xpath(:playlist_order) +
                   values_from_xpath(:sonyci_id) +
                   values_from_xpath(:organization) +
                   values_from_xpath(:canonical_meta_tag) +
                   values_from_xpath(:special_collection_category)
      remove_exactly_once_from_array all_vals, with_types
    end

    def ams_id
      values_from_xpath('//pbcoreIdentifier[@source="http://americanarchiveinventory.org"]').first.gsub('cpb-aacip/', 'cpb-aacip_')
    end

    def dates_without_digitized_date_type
      values_from_xpath('//instantiationDate') - values_from_xpath(:digitization_date)
    end

    def local_instantiation_identifiers_without_ams_id
      values_from_xpath('//instantiationIdentifier') - values_from_xpath('//instantiationIdentifier[@source="ams"]')
    end

    def contributors_attrs
      noko.xpath('//pbcoreContributor').map do |contributor|
        {
          contributor: contributor.xpath('//contributor').first.text,
          affiliation: contributor.xpath('//contributor').first.attributes['affiliation'].value,
          contributor_role: contributor.xpath('//contributorRole').first.text,
          portrayal: contributor.xpath('//contributorRole').first.attributes['portrayal'].value,
        }
      end
    end

    def frame_width
      noko.xpath('//essenceTrackFrameSize').first.text.split('x').first
    end

    def frame_height
      noko.xpath('//essenceTrackFrameSize').first.text.split('x').last
    end

    private

      # Does a proper array subtraction that the minus operator does not do.
      # The minus operator `-` on arrays will remove ALL occurences of the right
      # operand from the left operand and return the result. We need to be able
      # to remove values just once, leaving any others that may be present.
      # @param [Array] orig_array an array of values you want to remove from.
      # @param [Array] remove_these an array of values you want to remove from
      #   orig_array
      # @return [Array] the result of removing each occurrence of remove_these
      #   from orig_array exactly once.
      def remove_exactly_once_from_array(orig_array, remove_these)
        return_array = orig_array.dup
        remove_these.each do |val|
          remove_this_index = return_array.index val
          return_array.slice! remove_this_index if remove_this_index
        end
        return_array
      end
  end
end

# Include the helper if the :pbcore_xpath_helpers flag is set on the context
# or example.
RSpec.configure do |config|
  config.include PBCoreXPathHelper, :pbcore_xpath_helper
end
