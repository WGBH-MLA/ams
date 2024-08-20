# Module AMS::PbcoreXmlExportExtension
# This module is an extension of blacklight to export the record in PBCore XML format
module AMS::PbcoreXmlExportExtension
  def self.extended(document)
    document.will_export_as(:pbcore, "application/xml")
  end

  def export_as_pbcore
    pbcore_builder = pbcore_xml_builder # Method to prepare the PBCore XML
    pbcore_builder.to_xml # Return PBCore XML
  end

  private

  def pbcore_xml_builder
    Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
      xml.pbcoreDescriptionDocument('xmlns' => 'http://www.pbcore.org/PBCore/PBCoreNamespace.html', 'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance', 'xsi:schemaLocation' => 'http://www.pbcore.org/PBCore/PBCoreNamespace.html http://www.pbcore.org/xsd/pbcore-2.1.xsd') do
        # Add asset information on the root node of the XML
        prepare_asset(xml)
        # Create a root instantiation node
      end
    end
  end

  def prepare_asset(xml)
    # Asset Type
    asset_types.to_a.each { |type| xml.pbcoreAssetType { xml.text(type) } }
    # Dates
    created_date.to_a.each { |date| xml.pbcoreAssetDate(dateType: 'Created') { xml.text(date) } }
    broadcast_date.to_a.each { |date|  xml.pbcoreAssetDate(dateType: 'Broadcast') { xml.text(date) }  }
    copyright_date.to_a.each { |date|  xml.pbcoreAssetDate(dateType: 'Copyright') { xml.text(date) }  }
    self.date.to_a.each { |date| xml.pbcoreAssetDate { xml.text(date) } }

    # Identifiers
    pbs_nola_code.to_a.each { |pbs_nola_code| xml.pbcoreIdentifier(source: 'NOLA Code') { xml.text(pbs_nola_code) } }
    sonyci_id.to_a.each { |sonyci_id| xml.pbcoreIdentifier(source: 'Sony Ci') { xml.text(sonyci_id) } }
    eidr_id.to_a.each { |_local_identifier| xml.pbcoreIdentifier(source: 'EIDR') { xml.text(eidr_id.first) } }
    xml.pbcoreIdentifier(source: 'http://americanarchiveinventory.org') { xml.text(id) }
    local_identifier.to_a.each { |local_identifier| xml.pbcoreIdentifier(source: 'Local Identifier') { xml.text(local_identifier) } }

    # Titles
    self['title_tesim'].to_a.each { |title| xml.pbcoreTitle { xml.text(title) } }
    series_title.to_a.each { |title| xml.pbcoreTitle(titleType: 'Series') { xml.text(title) } }
    program_title.to_a.each { |title| xml.pbcoreTitle(titleType: 'Program') { xml.text(title) } }
    episode_title.to_a.each { |title| xml.pbcoreTitle(titleType: 'Episode') { xml.text(title) } }
    episode_number.to_a.each { |title| xml.pbcoreTitle(titleType: 'Episode Number') { xml.text(title) } }
    segment_title.to_a.each { |title| xml.pbcoreTitle(titleType: 'Segment') { xml.text(title) } }
    clip_title.to_a.each { |title| xml.pbcoreTitle(titleType: 'Clip') { xml.text(title) } }
    promo_title.to_a.each { |title| xml.pbcoreTitle(titleType: 'Promo') { xml.text(title) } }
    raw_footage_title.to_a.each { |title| xml.pbcoreTitle(titleType: 'Raw Footage') { xml.text(title) } }

    # Subject
    subject.to_a.each { |subject| xml.pbcoreSubject { xml.text(subject) } }

    # Descriptions
    self['description_tesim'].to_a.each { |description| xml.pbcoreDescription { xml.text(description) } }
    series_description.to_a.each { |description| xml.pbcoreDescription(descriptionType: 'Series') { xml.text(description) } }
    program_description.to_a.each { |description| xml.pbcoreDescription(descriptionType: 'Program') { xml.text(description) } }
    episode_description.to_a.each { |description| xml.pbcoreDescription(descriptionType: 'Episode') { xml.text(description) } }
    segment_description.to_a.each { |description| xml.pbcoreDescription(descriptionType: 'Segment') { xml.text(description) } }
    clip_description.to_a.each { |description| xml.pbcoreDescription(descriptionType: 'Clip') { xml.text(description) } }
    promo_description.to_a.each { |description| xml.pbcoreDescription(descriptionType: 'Promo') { xml.text(description) } }
    raw_footage_description.to_a.each { |description| xml.pbcoreDescription(descriptionType: 'Raw Footage') { xml.text(description) } }

    # Genre
    genre.to_a.each { |genre| xml.pbcoreGenre(source: 'AAPB Format Genre', annotation: 'genre') { xml.text(genre) } }

    # Topic
    topics.to_a.each { |topic| xml.pbcoreGenre(source: 'AAPB Topical Genre', annotation: 'topic') { xml.text(topic) } }

    # no pbcoreRelation
      # no pbcoreRelationType
      # no pbcoreRelationIdentifier

    # Spatial Coverage
    spatial_coverage.to_a.each do |coverage|
      xml.pbcoreCoverage do |coverage_node|
        coverage_node.coverage { coverage_node.text(coverage) }
        coverage_node.coverageType { coverage_node.text('Spatial') }
      end
    end
    # Temporal Coverage
    temporal_coverage.to_a.each do |coverage|
      xml.pbcoreCoverage do |coverage_node|
        coverage_node.coverage { coverage_node.text(coverage) }
        coverage_node.coverageType { coverage_node.text('Temporal') }
      end
    end

    # Audience level
    audience_level.to_a.each { |aud_level| xml.pbcoreAudienceLevel { xml.text(aud_level) } }

    # Audience Rating
    audience_rating.to_a.each { |aud_rating| xml.pbcoreAudienceRating { xml.text(aud_rating) } }

    # Producing Org
    producing_organization.to_a.each do |org|
      xml.pbcoreCreator do |creator_node|
        creator_node.creator { creator_node.text(org) }
        creator_node.creatorRole { creator_node.text('Producing Organization') }
      end
    end

    members(only: Contribution).each do |contribution|
      xml.pbcoreContributor do |contributor_node|
        contributor_node.contributor { contributor_node.text(contribution&.contributor&.first) }

        # contributorRole is not required!
        contributor_node.contributorRole { contributor_node.text(contribution&.contributor_role&.first) } if contribution.contributor_role
      end
    end
    # people_with_types = members(only: Contribution).sort_by {|peep| peep.contributor_role }

    # Creators
    # people_with_types['creator'].each do |contributor|
    #   xml.pbcoreContributor do |creator_node|
    #     creator_node.creator { creator_node.text(contribution.contributor.first) }
    #     creator_node.creatorRole { creator_node.text(contribution.contributor_role.first) }
    #   end
    # end

    # # Contributors
    # people_with_types['contributor'].each do |contributor|
    #   xml.pbcoreContributor do |contributor_node|
    #     contributor_node.contributor { contributor_node.text(contribution.contributor.first) }
    #     contributor_node.contributorRole { contributor_node.text(contribution.contributor_role.first) }
    #   end
    # end

    # # Publishers
    # people_with_types['publisher'].each do |contributor|
    #   xml.pbcoreContributor do |publisher_node|
    #     publisher_node.publisher { publisher_node.text(contribution.contributor.first) }
    #     publisher_node.publisherRole { publisher_node.text(contribution.contributor_role.first) }
    #   end
    # end

    # Rights Summary
    rights_summary.to_a.each do |rights_summary|
      # xml.pbcoreRightsSummary( xml.rightsSummary(  ) )
      xml.pbcoreRightsSummary do |rights_node|
        rights_node.rightsSummary { xml.cdata(rights_summary) }
      end
    end

    # Rights Link
    rights_link.to_a.each do |rights_link|
      # xml.pbcoreRightsSummary( xml.rightsSummary(  ) )
      xml.pbcoreRightsSummary do |rights_node|
        rights_node.rightsLink { xml.cdata(rights_link) }
      end
    end

    # make sure that manipulating 'xml' inside this func is still in scope
    prepare_instantiations(xml)

    # Annotation from the annotation property on Asset
    annotation.to_a.each { |annotation| xml.pbcoreAnnotation { xml.cdata(annotation) } }

    # Add method here to process associated Annotations
    prepare_annotations(xml)
  end

  def prepare_instantiations(xml)
    members(only: PhysicalInstantiation).each do |instantiation|
      prepare_physical_instantiation(xml, instantiation) # separate method to put child nodes for the physical instantiation
    end
    members(only: DigitalInstantiation).each do |instantiation|
      prepare_digital_instantiation(xml, instantiation) # separate method to put child nodes for the physical instantiation
    end
  end

  def prepare_physical_instantiation(xml, instantiation)
    xml.pbcoreInstantiation do |instantiation_node|

      instantiation_node.instantiationIdentifier(source: 'Filename') { instantiation_node.text(instantiation.id) }
      instantiation.local_instantiation_identifier.to_a.each { |local_instantiation_identifier| instantiation_node.instantiationIdentifier { instantiation_node.text(local_instantiation_identifier) } }

      instantiation.date&.to_a&.each { |date|  instantiation_node.instantiationDate { instantiation_node.text(date) } }
      instantiation.digitization_date&.to_a&.each { |date| instantiation_node.instantiationDate(dateType: 'digitized') { instantiation_node.text(date) } }

      instantiation.dimensions&.to_a&.each { |dimension| instantiation_node.instantiationDimensions { instantiation_node.text(dimension) } }

      instantiation.format&.to_a&.each { |format| instantiation_node.instantiationPhysical { instantiation_node.text(format) } }

      instantiation.standard&.to_a&.each { |standard|  instantiation_node.instantiationStandard { instantiation_node.text(standard) }  }

      instantiation.location&.to_a&.each { |location|  instantiation_node.instantiationLocation { instantiation_node.text(location) }  }

      instantiation.media_type&.to_a&.each { |media_type| instantiation_node.instantiationMediaType { instantiation_node.text(media_type) }  }

      instantiation.generations&.to_a&.each { |generation| instantiation_node.instantiationGenerations { instantiation_node.text(generation) } }

      instantiation.time_start&.to_a&.each { |time_start| instantiation_node.instantiationTimeStart { instantiation_node.text(time_start) }  }

      instantiation.duration&.to_a&.each { |duration| instantiation_node.instantiationDuration { instantiation_node.text(duration) } }

      instantiation.colors&.to_a&.each { |color| instantiation_node.instantiationColors { instantiation_node.text(color) } }

      instantiation.tracks&.to_a&.each { |tracks| instantiation_node.instantiationTracks { instantiation_node.text(tracks) }  }

      instantiation.channel_configuration&.to_a&.each { |channel_config| instantiation_node.instantiationChannelConfiguration { instantiation_node.text(channel_config) } }

      instantiation.language&.to_a&.each { |language| instantiation_node.instantiationLanguage { instantiation_node.text(language) } }

      instantiation.alternative_modes&.to_a&.each { |alternative_mode|  instantiation_node.instantiationAlternativeModes { instantiation_node.text(alternative_mode) }  }

      # Prepare Essence Track node
      instantiation.members(only: EssenceTrack).each do |essence_track|
        prepare_essence_track(instantiation_node, essence_track)
      end

      instantiation.rights_summary&.to_a&.each do |rights_summary|
        instantiation_node.instantiationRights do |instrights_node|
          instrights_node.rightsSummary { instantiation_node.cdata(rights_summary) }
        end
      end

      instantiation.rights_link&.to_a&.each do |rights_link|
        instantiation_node.instantiationRights do |instrights_node|
          instrights_node.rightsLink { instantiation_node.cdata(rights_link) }
        end
      end

      instantiation.annotation&.to_a&.each { |annTxt| instantiation_node.instantiationAnnotation { instantiation_node.cdata(annTxt) } }
      instantiation.holding_organization&.to_a&.each { |org| instantiation_node.instantiationAnnotation(annotationType: 'organization') { instantiation_node.text(org) } }

    end
  end

  def prepare_digital_instantiation(xml, instantiation)
    xml.pbcoreInstantiation do |instantiation_node|
      instantiation_node.instantiationIdentifier { instantiation_node.text(instantiation.id) }
      instantiation.local_instantiation_identifier.to_a.each { |local_instantiation_identifier| instantiation_node.instantiationIdentifier { instantiation_node.text(local_instantiation_identifier) } }

      instantiation.md5&.to_a&.each { |md5| instantiation_node.instantiationIdentifier(source: 'md5') { instantiation_node.text(md5) } }

      instantiation.date&.to_a&.each { |date|  instantiation_node.instantiationDate { instantiation_node.text(date) } }
      instantiation.digitization_date&.to_a&.each { |date| instantiation_node.instantiationDate(dateType: 'digitized') { instantiation_node.text(date) } }

      instantiation.dimensions&.to_a&.each { |dimension| instantiation_node.instantiationDimensions(unitsOfMeasure: '') { instantiation_node.text(dimension) } }

      instantiation.digital_format&.to_a&.each { |format| instantiation_node.instantiationDigital { instantiation_node.text(format) } }

      instantiation.standard&.to_a&.each { |standard|  instantiation_node.instantiationStandard { instantiation_node.text(standard) }  }

      instantiation.location&.to_a&.each { |location|  instantiation_node.instantiationLocation { instantiation_node.text(location) }  }

      instantiation.media_type&.to_a&.each { |media_type| instantiation_node.instantiationMediaType { instantiation_node.text(media_type) }  }

      instantiation.generations&.to_a&.each { |generation| instantiation_node.instantiationGenerations { instantiation_node.text(generation) } }

      instantiation.file_size&.to_a&.each { |file_size| instantiation_node.instantiationFileSize { instantiation_node.text(file_size) } }

      instantiation.time_start&.to_a&.each { |time_start| instantiation_node.instantiationTimeStart { instantiation_node.text(time_start) } }

      instantiation.duration&.to_a&.each { |duration| instantiation_node.instantiationDuration { instantiation_node.text(duration) } }

      # no dataRate

      instantiation.colors&.to_a&.each { |color| instantiation_node.instantiationColors { instantiation_node.text(color) } }

      instantiation.tracks&.to_a&.each { |tracks| instantiation_node.instantiationTracks { instantiation_node.text(tracks) }  }

      instantiation.channel_configuration&.to_a&.each { |channel_config| instantiation_node.instantiationChannelConfiguration { instantiation_node.text(channel_config) } }

      instantiation.language&.to_a&.each { |language| instantiation_node.instantiationLanguage { instantiation_node.text(language) } }

      instantiation.alternative_modes&.to_a&.each { |alternative_mode|  instantiation_node.instantiationAlternativeModes { instantiation_node.text(alternative_mode) }  }

      # Prepare Essence Track node
      instantiation.members(only: EssenceTrack).each do |essence_track|
        prepare_essence_track(instantiation_node, essence_track)
      end

      # instantiationRelation

      instantiation.rights_summary.to_a.each do |rights_summary|
        instantiation.instantiationRights do |instrights_node|
          instrights_node.rightsSummary { instantiation_node.cdata(rights_summary) }
        end
      end

      instantiation.rights_link.to_a.each do |rights_link|
        instantiation.instantiationRights do |instrights_node|
          instrights_node.rightsLink { instantiation_node.cdata(rights_link) }
        end
      end

      instantiation.annotation&.to_a&.each { |annTxt| instantiation_node.instantiationAnnotation { instantiation_node.cdata(annTxt) } }
      instantiation.holding_organization&.to_a&.each { |org| instantiation_node.instantiationAnnotation(annotationType: 'organization') { instantiation_node.text(org) } }
    end
  end

  def prepare_essence_track(instantiation_node, essence_track)
    instantiation_node.instantiationEssenceTrack do |essence_track_node|

      essence_track_node.essenceTrackType { essence_track_node.text(essence_track.track_type&.first) }

      essence_track.track_id&.to_a&.each { |track_id| essence_track_node.essenceTrackIdentifier { essence_track_node.text(track_id) } }

      essence_track_node.essenceTrackStandard { essence_track_node.text(essence_track.standard&.first) } if content?(essence_track.standard)

      essence_track_node.essenceTrackEncoding { essence_track_node.text(essence_track.encoding&.first) } if content?(essence_track.encoding)

      essence_track_node.essenceTrackDataRate(unitsOfMeasure: 'kb/s') { essence_track_node.text(essence_track.data_rate&.first) } if content?(essence_track.data_rate)

      essence_track_node.essenceTrackFrameRate { essence_track_node.text(essence_track.frame_rate&.first) } if content?(essence_track.frame_rate)

      essence_track_node.essenceTrackPlaybackSpeed(unitsOfMeasure: essence_track.playback_speed_units) { essence_track_node.text(essence_track.playback_speed) } if content?(essence_track.playback_speed)

      essence_track_node.essenceTrackSamplingRate { essence_track_node.text(essence_track.sample_rate&.first) } if content?(essence_track.sample_rate)

      essence_track_node.essenceTrackBitDepth { essence_track_node.text(essence_track.bit_depth&.first) } if content?(essence_track.bit_depth)

      essence_track_node.essenceTrackFrameSize { essence_track_node.text("#{essence_track.frame_width} x #{essence_track.frame_height}") } if essence_track.frame_width && essence_track.frame_height

      essence_track_node.essenceTrackAspectRatio { essence_track_node.text(essence_track.aspect_ratio&.first) } if content?(essence_track.aspect_ratio)

      essence_track_node.essenceTrackTimeStart { essence_track_node.text(essence_track.time_start&.first) } if content?(essence_track.time_start)

      essence_track_node.essenceTrackDuration { essence_track_node.text(essence_track.duration&.first) } if content?(essence_track.duration)

      essence_track.language&.to_a&.each { |lang| essence_track_node.essenceTrackLanguage { essence_track_node.text(lang) } }

      essence_track.annotation&.to_a&.each { |annTxt| essence_track_node.essenceTrackAnnotation { essence_track_node.text(annTxt) } }
    end
  end

  def prepare_annotations(xml)
    return if annotations.blank?

    annotations.each do |annotation|
      xml.pbcoreAnnotation(annotationType: AnnotationTypesService.new.label(annotation.annotation_type), ref: annotation.ref, source: annotation.source, annotation: annotation.annotation, version: annotation.version) { xml.text(annotation.value) }
    end
  end

  private

    def content?(data_node)
      return false if data_node.nil? || (data_node.is_a?(Array) && data_node.first.blank?) || data_node.blank?
      true
    end
end
