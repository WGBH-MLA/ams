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

  def pbcore_xml_builder
    Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
      xml.pbcoreDescriptionDocument('xmlns' => 'http://www.pbcore.org/PBCore/PBCoreNamespace.html', 'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance', 'xsi:schemaLocation' => 'http://www.pbcore.org/PBCore/PBCoreNamespace.html http://www.pbcore.org/xsd/pbcore-2.0.xsd') do
        # Add asset information on the root node of the XML
        prepare_asset(xml)
        # Create a root instantiation node
        prepare_instantiations(xml)
      end
    end
  end

  def prepare_asset(xml)
    # Asset Type
    asset_types.to_a.each { |type| xml.pbcoreAssetType { xml.text(type) } }
    # Dates
    created_date.to_a.each { |date| xml.pbcoreAssetDate(dateType: 'created') { xml.text(date) } }
    broadcast_date.to_a.each { |date|  xml.pbcoreAssetDate(dateType: 'broadcast') { xml.text(date) }  }
    copyright_date.to_a.each { |date|  xml.pbcoreAssetDate(dateType: 'copyright') { xml.text(date) }  }
    self.date.to_a.each { |date| xml.pbcoreAssetDate { xml.text(date) } }

    # Identifiers
    pbs_nola_code.to_a.each { |pbs_nola_code| xml.pbcoreIdentifier(source: 'NOLA Code') { xml.text(pbs_nola_code) } }
    sonyci_id.to_a.each { |sonyci_id| xml.pbcoreIdentifier(source: 'Sony Ci') { xml.text(sonyci_id) } }
    eidr_id.to_a.each { |_local_identifier| xml.pbcoreIdentifier(source: 'EIDR') { xml.text(eidr_id.first) } }

    xml.pbcoreIdentifier(source: 'http://americanarchiveinventory.org') { xml.text(id) }

    # Titles
    self['title'].to_a.each { |title| xml.pbcoreTitle { xml.text(title) } }
    series_title.to_a.each { |title| xml.pbcoreTitle(source: 'Series') { xml.text(title) } }
    program_title.to_a.each { |title| xml.pbcoreTitle(source: 'Program') { xml.text(title) } }
    episode_title.to_a.each { |title| xml.pbcoreTitle(source: 'Episode') { xml.text(title) } }
    episode_number.to_a.each { |title| xml.pbcoreTitle(source: 'Episode Number') { xml.text(title) } }
    segment_title.to_a.each { |title| xml.pbcoreTitle(source: 'Segment') { xml.text(title) } }
    clip_title.to_a.each { |title| xml.pbcoreTitle(source: 'Clip') { xml.text(title) } }
    promo_title.to_a.each { |title| xml.pbcoreTitle(source: 'Promo') { xml.text(title) } }
    raw_footage_title.to_a.each { |title| xml.pbcoreTitle(source: 'Raw Footage') { xml.text(title) } }

    # Descriptions
    self['description'].to_a.each { |description| xml.pbcoreDescription { xml.text(description) } }
    series_description.to_a.each { |description| xml.pbcoreDescription(source: 'Series') { xml.text(description) } }
    program_description.to_a.each { |description| xml.pbcoreDescription(source: 'Program') { xml.text(description) } }
    episode_description.to_a.each { |description| xml.pbcoreDescription(source: 'Episode') { xml.text(description) } }
    segment_description.to_a.each { |description| xml.pbcoreDescription(source: 'Segment') { xml.text(description) } }
    clip_description.to_a.each { |description| xml.pbcoreDescription(source: 'Clip') { xml.text(description) } }
    promo_description.to_a.each { |description| xml.pbcoreDescription(source: 'Promo') { xml.text(description) } }
    raw_footage_description.to_a.each { |description| xml.pbcoreDescription(source: 'Raw Footage') { xml.text(description) } }

    # Genre
    genre.to_a.each { |genre| xml.pbcoreGenre(source: 'AAPB Format Genre') { xml.text(genre) } }

    # Topic
    topics.to_a.each { |topic| xml.pbcoreGenre(source: 'AAPB Topical Genre') { xml.text(topic) } }

    # Producing Org
    producing_organization.to_a.each do |org|
      xml.pbcoreCreator do |creator_node|
        creator_node.creator { creator_node.text(org) }
        creator_node.creatorRole { creator_node.text('Producing Organization') }
      end
    end

    # Spatial Coverage
    spatial_coverage.to_a.each do |coverage|
      xml.pbcoreCoverage do |creator_node|
        creator_node.coverage(source: 'Wikipedia', ref: 'http://en.wikipedia.org/wiki/Werowocomoco') { creator_node.text(coverage) }
        creator_node.coverageType(source: 'PBCore coverageType', ref: 'http://pbcore.org/vocabularies/coverageType#spatial') { creator_node.text('Spatial') }
      end
    end

    # Temporal Coverage
    temporal_coverage.to_a.each do |coverage|
      xml.pbcoreCoverage do |creator_node|
        creator_node.coverage(source: 'Wikipedia', ref: 'http://en.wikipedia.org/wiki/Werowocomoco') { creator_node.text(coverage) }
        creator_node.coverageType(source: 'PBCore coverageType', ref: 'http://pbcore.org/vocabularies/coverageType#spatial') { creator_node.text('Temporal') }
      end
    end

    # Audience level
    audience_level.to_a.each { |aud_level| xml.pbcoreAudienceLevel { xml.text(aud_level) } }

    # Audience Rating
    audience_rating.to_a.each { |aud_rating| xml.pbcoreAudienceRating { xml.text(aud_rating) } }

    # Anotations
    annotation.to_a.each { |annotation| xml.pbcoreAnnotation { xml.cdata(annotation) } }

    # Rights Summary
    rights_summary.to_a.each { |rights_summary| xml.rightsSummary { xml.cdata(rights_summary) } }

    # local_identifier
    local_identifier.to_a.each { |local_identifier| xml.pbcoreIdentifier(source: 'Local Identifier') { xml.text(local_identifier) } }

    # Subject
    subject.to_a.each { |subject| xml.pbcoreSubject { xml.text(subject) } }

    # Contributor
    find_child(Contribution).each do |contribution|
      xml.pbcoreContributor do |creator_node|
        creator_node.creator { creator_node.text(contribution.contributor.first) }
        creator_node.creatorRole { creator_node.text(contribution.contributor_role.first) }
      end
    end

    # AAPB Admin Data
    level_of_user_access.to_a.each { |annotation| xml.pbcoreAnnotation(annotationType: 'Level of User Access') { xml.cdata(annotation) } }
    minimally_cataloged.to_a.each { |annotation| xml.pbcoreAnnotation(annotationType: 'cataloging staus') { xml.cdata(annotation) } }
    outside_url.to_a.each { |annotation| xml.pbcoreAnnotation(annotationType: 'Outside URL') { xml.cdata(annotation) } }
    transcript_status.to_a.each { |annotation| xml.pbcoreAnnotation(annotationType: 'Transcript Status') { xml.cdata(annotation) } }
    licensing_info.to_a.each { |annotation| xml.pbcoreAnnotation(annotationType: 'Licensing Info') { xml.cdata(annotation) } }
    playlist_group.to_a.each { |annotation| xml.pbcoreAnnotation(annotationType: 'Playlist Group') { xml.cdata(annotation) } }
    playlist_order.to_a.each { |annotation| xml.pbcoreAnnotation(annotationType: 'Playlist Order') { xml.cdata(annotation) } }

    special_collection.to_a.each { |annotation| xml.pbcoreAnnotation(annotationType: 'special_collections') { xml.cdata(annotation) } }
    self.sonyci_id.to_a.each { |annotation| xml.pbcoreAnnotation(annotationType: 'Sony Ci') { xml.cdata(annotation) } }
  end

  def prepare_instantiations(xml)
    find_child(PhysicalInstantiation).each do |instantiation|
      prepare_physical_instantiation(xml, instantiation) # separate method to put child nodes for the physical instantiation
    end
    find_child(DigitalInstantiation).each do |instantiation|
      prepare_digital_instantiation(xml, instantiation) # separate method to put child nodes for the physical instantiation
    end
  end

  def prepare_physical_instantiation(xml, instantiation)
    xml.pbcoreInstantiation do |instantiation_node|
      instantiation_node.instantiationIdentifier { instantiation_node.text(instantiation.id) }
      instantiation.date.to_a.each { |date|  instantiation_node.instantiationDate { instantiation_node.text(date) } }
      instantiation.digitization_date.to_a.each { |date| instantiation_node.instantiationDate(dateType: 'digitized') { instantiation_node.text(date) } }
      instantiation.dimensions.to_a.each { |dimension| instantiation_node.instantiationDimensions { instantiation_node.text(dimension) } }
      instantiation.format.to_a.each { |format| instantiation_node.instantiationPhysical { instantiation_node.text(format) } }
      instantiation.standard.to_a.each { |standard|  instantiation_node.instantiationStandard { instantiation_node.text(standard) }  }
      instantiation.location.to_a.each { |location|  instantiation_node.instantiationLocation { instantiation_node.text(location) }  }
      instantiation.media_type.to_a.each { |media_type| instantiation_node.instantiationMediaType { instantiation_node.text(media_type) }  }
      instantiation.generations.to_a.each { |generation| instantiation_node.instantiationGenerations { instantiation_node.text(generation) } }
      instantiation.time_start.to_a.each { |time_start| instantiation_node.instantiationTimeStart { instantiation_node.text(time_start) }  }
      instantiation.duration.to_a.each { |duration| instantiation_node.instantiationDuration { instantiation_node.text(duration) } }
      instantiation.colors.to_a.each { |color| instantiation_node.instantiationColors { instantiation_node.text(color) } }
      instantiation.language.to_a.each { |language| instantiation_node.instantiationLanguage { instantiation_node.text(language) } }
      instantiation.rights_summary.to_a.each { |rights_summary| instantiation_node.rightsSummary { instantiation_node.cdata(rights_summary) } }
      instantiation.rights_link.to_a.each { |rights_link|  instantiation_node.rightsLink { instantiation_node.text(rights_link) } }
      instantiation.annotation.to_a.each { |annTxt| instantiation_node.pbcoreAnnotation { instantiation_node.cdata(annTxt) } }
      instantiation.local_instantiation_identifer.to_a.each { |local_instantiation_identifer| instantiation_node.instantiationIdentifier { instantiation_node.text(local_instantiation_identifer) } }
      instantiation.tracks.to_a.each { |tracks| instantiation_node.instantiationTracks { instantiation_node.text(tracks) }  }
      instantiation.channel_configuration.to_a.each { |channel_config| instantiation_node.instantiationChannelConfiguration { instantiation_node.text(channel_config) } }
      instantiation.alternative_modes.to_a.each { |alternative_mode|  instantiation_node.instantiationAlternativeModes { instantiation_node.text(alternative_mode) }  }
      instantiation.alternative_modes.to_a.each { |alternative_mode|  instantiation_node.instantiationAlternativeModes { instantiation_node.text(alternative_mode) }  }
      instantiation.holding_organization.to_a.each { |org| instantiation_node.instantiationAnnotation(annotationType: 'Organization') { instantiation_node.text(org) } }

      # Prepare Essence Track node
      instantiation.find_child(EssenceTrack).each do |essence_track|
        prepare_essence_track(instantiation_node, essence_track)
      end
    end
  end

  def prepare_digital_instantiation(xml, instantiation)
    xml.pbcoreInstantiation do |instantiation_node|
      instantiation_node.instantiationIdentifier { instantiation_node.text(instantiation.id) }
      instantiation.date.to_a.each { |date|  instantiation_node.instantiationDate { instantiation_node.text(date) } }
      instantiation.digitization_date.to_a.each { |date| instantiation_node.instantiationDate(dateType: 'digitized') { instantiation_node.text(date) } }
      instantiation.dimensions.to_a.each { |dimension| instantiation_node.instantiationDimensions(unitsOfMeasure: '') { instantiation_node.text(dimension) } }
      instantiation.format.to_a.each { |format| instantiation_node.instantiationPhysical { instantiation_node.text(format) } }
      instantiation.standard.to_a.each { |standard|  instantiation_node.instantiationStandard { instantiation_node.text(standard) }  }
      instantiation.location.to_a.each { |location|  instantiation_node.instantiationLocation { instantiation_node.text(location) }  }
      instantiation.media_type.to_a.each { |media_type| instantiation_node.instantiationMediaType { instantiation_node.text(media_type) }  }
      instantiation.generations.to_a.each { |generation| instantiation_node.instantiationGenerations { instantiation_node.text(generation) } }
      instantiation.file_size.to_a.each { |file_size| instantiation_node.instantiationFileSize { instantiation_node.text(file_size) } }
      instantiation.time_start.to_a.each { |time_start| instantiation_node.instantiationTimeStart { instantiation_node.text(time_start) } }
      instantiation.duration.to_a.each { |duration| instantiation_node.instantiationDuration { instantiation_node.text(duration) } }
      instantiation.colors.to_a.each { |color| instantiation_node.instantiationColors { instantiation_node.text(color) } }
      instantiation.language.to_a.each { |language| instantiation_node.instantiationLanguage { instantiation_node.text(language) } }
      instantiation.rights_summary.to_a.each { |rights_summary| instantiation_node.rightsSummary { instantiation_node.cdata(rights_summary) } }
      instantiation.rights_link.to_a.each { |rights_link|  instantiation_node.rightsLink { instantiation_node.text(rights_link) } }
      instantiation.annotation.to_a.each { |annTxt| instantiation_node.pbcoreAnnotation { instantiation_node.cdata(annTxt) } }
      instantiation.local_instantiation_identifer.to_a.each { |local_instantiation_identifer| instantiation_node.instantiationIdentifier { instantiation_node.text(local_instantiation_identifer) } }
      instantiation.tracks.to_a.each { |tracks| instantiation_node.instantiationTracks { instantiation_node.text(tracks) }  }
      instantiation.channel_configuration.to_a.each { |channel_config| instantiation_node.instantiationChannelConfiguration { instantiation_node.text(channel_config) } }
      instantiation.alternative_modes.to_a.each { |alternative_mode|  instantiation_node.instantiationAlternativeModes { instantiation_node.text(alternative_mode) }  }
      instantiation.alternative_modes.to_a.each { |alternative_mode|  instantiation_node.instantiationAlternativeModes { instantiation_node.text(alternative_mode) }  }
      instantiation.holding_organization.to_a.each { |org| instantiation_node.instantiationAnnotation(annotationType: 'Organization') { instantiation_node.text(org) } }

      # Prepare Essence Track node
      instantiation.find_child(EssenceTrack).each do |essence_track|
        prepare_essence_track(instantiation_node, essence_track)
      end
    end
  end

  def prepare_essence_track(instantiation_node, essence_track)
    instantiation_node.instantiationEssenceTrack do |essence_track_node|
      essence_track_node.essenceTrackType { essence_track_node.text(essence_track.track_type.first) }
      essence_track.track_id.to_a.each { |track_id| essence_track_node.essenceTrackIdentifier { essence_track_node.text(track_id) } }
      essence_track_node.essenceTrackStandard { essence_track_node.text(essence_track.standard.first) } if content?(essence_track.standard)
      essence_track_node.essenceTrackEncoding { essence_track_node.text(essence_track.encoding.first) } if content?(essence_track.encoding)
      essence_track_node.essenceTrackFrameRate { essence_track_node.text(essence_track.frame_rate.first) } if content?(essence_track.frame_rate)
      essence_track_node.essenceTrackBitDepth { essence_track_node.text(essence_track.bit_depth.first) } if content?(essence_track.bit_depth)
      essence_track_node.essenceTrackAspectRatio { essence_track_node.text(essence_track.aspect_ratio.first) } if content?(essence_track.aspect_ratio)
      essence_track_node.essenceTrackDuration { essence_track_node.text(essence_track.duration.first) } if content?(essence_track.duration)
      essence_track_node.essenceTrackDataRate(unitsOfMeasure: 'kb/s') { essence_track_node.text(essence_track.data_rate.first) } if content?(essence_track.data_rate)
      essence_track_node.essenceTrackFrameSize { essence_track_node.text("#{essence_track.frame_width} x #{essence_track.frame_height}") } if essence_track.frame_width && essence_track.frame_height
      essence_track_node.essenceTrackPlaybackSpeed(unitsOfMeasure: 'inches per second') { essence_track_node.text(essence_track.playback_inch_per_sec.first) } if content?(essence_track.playback_inch_per_sec)
      essence_track_node.essenceTrackPlaybackSpeed(unitsOfMeasure: 'frames per second') { essence_track_node.text(essence_track.playback_frame_per_sec.first) } if content?(essence_track.playback_frame_per_sec)
      essence_track_node.essenceTrackSamplingRate { essence_track_node.text(essence_track.sample_rate.first) } if content?(essence_track.sample_rate)
      essence_track_node.essenceTrackTimeStart { essence_track_node.text(essence_track.time_start.first) } if content?(essence_track.time_start)
      essence_track.language.to_a.each { |lang| essence_track_node.essenceTrackLanguage { essence_track_node.text(lang) } }
      essence_track.annotation.to_a.each { |annTxt| essence_track_node.essenceTrackAnnotation { essence_track_node.text(annTxt) } }
    end
  end

  private

    def content?(data_node)
      return false if data_node.nil? || (data_node.is_a?(Array) && data_node.first.blank?) || data_node.blank?
      true
    end
end
