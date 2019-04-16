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
      # Fially, map to #text (i.e. the value within the xml node).
      xpaths.flatten.map { |xp| noko.xpath(xp) }.select { |found| found.count > 0 }.flatten.map(&:text).map(&:strip)
    end

    def xpath_presets
      @xpath_presets ||= {
        program_title:                  '//pbcoreTitle[@titleType="Program"]',
        episode_title:                  '//pbcoreTitle[@titleType="Episode" or @titleType="Episode Title"]',
        segment_title:                  '//pbcoreTitle[@titleType="Segment"]',
        clip_title:                     '//pbcoreTitle[@titleType="Clip"]',
        promo_title:                    '//pbcoreTitle[@titleType="Promo"]',
        raw_footage_title:              '//pbcoreTitle[@titleType="Raw Footage"]',
        episode_number:                 '//pbcoreTitle[@titleType="Episode Number"]',
        description:                    '//pbcoreDescription[@descriptionType="Program"]',
        program_description:            '//pbcoreDescription[@descriptionType="Program"]',
        episode_description:            '//pbcoreDescription[@descriptionType="Episode" or @descriptionType="Episode Description"]',
        segment_description:            '//pbcoreDescription[@descriptionType="Segment"]',
        clip_description:               '//pbcoreDescription[@descriptionType="Clip"]',
        promo_description:              '//pbcoreDescription[@descriptionType="Promo"]',
        raw_footage_description:        '//pbcoreDescription[@descriptionType="Raw Footage"]',
        audience_level:                 '//pbcoreAudienceLevel',
        audience_rating:                '//pbcoreAudienceRating',
        asset_types:                    '//pbcoreAssetType',
        genre:                          '//pbcoreGenre',
        annotation:                     '//pbcoreAnnotation',
        rights_summary:                 '//pbcoreRightsSummary/rightsSummary',
        rights_link:                    '//pbcoreRightsSummary/rightsLink',
        local_identifier:               '//pbcoreIdentifier[@source="Local Identifier"]',
        pbs_nola_code:                  '//pbcoreIdentifier[@source="NOLA"]',
        eidr_id:                        '//pbcoreIdentifier[@source="EIDR"]',
        topics:                         '//pbcoreGenre[@source="AAPB Topical Genre"]',
        subject:                        '//pbcoreSubject',
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
        holding_organization:           '//instantiationAnnotation[@annotationType="Organization"]',

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
      with_types = values_from_xpath(:program_title) + values_from_xpath(:episode_title) + values_from_xpath(:segment_title) + values_from_xpath(:clip_title) + values_from_xpath(:promo_title) + values_from_xpath(:raw_footage_title) + values_from_xpath(:episode_number)
      with_types.each {|title| dex = all_titles.index(title); all_titles.slice!( dex ) if dex }
      all_titles
    end

    # Shortcut method to pull out all descriptions that don't match the other description
    # types.
    # Usage: In your spec, do this..
    #   pbcore_xpath_helper(pbcore_xml).descriptions_without_type
    def descriptions_without_type
      all_descs = values_from_xpath('//pbcoreDescription')
      with_types = values_from_xpath(:program_description) + values_from_xpath(:episode_description) + values_from_xpath(:segment_description) + values_from_xpath(:clip_description) + values_from_xpath(:promo_description) + values_from_xpath(:raw_footage_description) + values_from_xpath(:episode_number)
      with_types.each {|desc| dex = all_descs.index(desc); all_descs.slice!( dex ) if dex  }
      all_descs
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

  end
end

# Include the helper if the :pbcore_xpath_helpers flag is set on the context
# or example.
RSpec.configure do |config|
  config.include PBCoreXPathHelper, :pbcore_xpath_helper
end
