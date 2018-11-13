# Module AMS::PbcoreXmlExportExtension
# This module is an extension of blacklight to export the record in PBCore XML format
module AMS::PbcoreXmlExportExtension

  def self.extended(document)
    document.will_export_as(:pbcore, "application/xml")
  end

  def export_as_pbcore
    pbcore_xml = generate_pbcore2_xml # Method to prepare the PBCore XML
    pbcore_xml.to_xml # Return PBCore XML
  end

  def generate_pbcore2_xml
    b = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
      xml.pbcoreDescriptionDocument('xmlns' => 'http://www.pbcore.org/PBCore/PBCoreNamespace.html', 'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance', 'xsi:schemaLocation' => 'http://www.pbcore.org/PBCore/PBCoreNamespace.html http://www.pbcore.org/xsd/pbcore-2.0.xsd') do
        # Add asset information on the root node of the XML
        prepare_asset(xml)
        # Create a root instantiation node
        prepare_instantiation(xml)
      end
    end
  end

  def prepare_asset(xml)
    # Asset Type
    self.asset_types.to_a.each { |type| xml.pbcoreAssetType { xml.text(type) }}
    # Dates
    self.created_date.to_a.each { |date|  xml.pbcoreAssetDate(dateType: 'created') { xml.text(date) }  }
    self.broadcast_date.to_a.each { |date|  xml.pbcoreAssetDate(dateType: 'broadcast') { xml.text(date) }  }
    self.copyright_date.to_a.each { |date|  xml.pbcoreAssetDate(dateType: 'copyright') { xml.text(date) }  }
    self.date.to_a.each { |date|  xml.pbcoreAssetDate { xml.text(date) }  }

    # Identifiers
    self.pbs_nola_code.to_a.each { |pbs_nola_code|  xml.pbcoreIdentifier(source: 'NOLA Code') { xml.text(pbs_nola_code) }  }
    self.sonyci_id.to_a.each { |sonyci_id|  xml.pbcoreIdentifier(source: 'Sony Ci') { xml.text(sonyci_id) }  }
    xml.pbcoreIdentifier(source: 'http://americanarchiveinventory.org') { xml.text(id) }

    # Titles
    self['title'].to_a.each{ |title| xml.pbcoreTitle { xml.text(title) } }
    self.series_title.to_a.each{ |title| xml.pbcoreTitle(source: 'Series') { xml.text(title) } }
    self.program_title.to_a.each{ |title| xml.pbcoreTitle(source: 'Program') { xml.text(title) } }
    self.episode_title.to_a.each{ |title| xml.pbcoreTitle(source: 'Episode') { xml.text(title) } }
    self.episode_number.to_a.each{ |title| xml.pbcoreTitle(source: 'Episode Number') { xml.text(title) } }
    self.segment_title.to_a.each{ |title| xml.pbcoreTitle(source: 'Segment') { xml.text(title) } }
    self.clip_title.to_a.each{ |title| xml.pbcoreTitle(source: 'Clip') { xml.text(title) } }
    self.promo_title.to_a.each{ |title| xml.pbcoreTitle(source: 'Promo') { xml.text(title) } }
    self.raw_footage_title.to_a.each{ |title| xml.pbcoreTitle(source: 'Raw Footage') { xml.text(title) } }

    # Descriptions
    self['description'].to_a.each{ |description| xml.pbcoreDescription { xml.text(description) } }
    self.series_description.to_a.each{ |description| xml.pbcoreDescription(source: 'Series') { xml.text(description) } }
    self.program_description.to_a.each{ |description| xml.pbcoreDescription(source: 'Program') { xml.text(description) } }
    self.episode_description.to_a.each{ |description| xml.pbcoreDescription(source: 'Episode') { xml.text(description) } }
    self.segment_description.to_a.each{ |description| xml.pbcoreDescription(source: 'Segment') { xml.text(description) } }
    self.clip_description.to_a.each{ |description| xml.pbcoreDescription(source: 'Clip') { xml.text(description) } }
    self.promo_description.to_a.each{ |description| xml.pbcoreDescription(source: 'Promo') { xml.text(description) } }
    self.raw_footage_description.to_a.each{ |description| xml.pbcoreDescription(source: 'Raw Footage') { xml.text(description) } }

    # Genre
    self.genre.to_a.each{ |genre| xml.pbcoreGenre( source:'AAPB Format Genre' ) { xml.text(genre) } }

    # Topic
    self.topics.to_a.each{ |topic| xml.pbcoreGenre( source:'AAPB Topical Genre' ) { xml.text(topic) } }

    # Producing Org
    self.producing_organization.to_a.each do |org|
      xml.pbcoreCreator do |creator_node|
        creator_node.creator { creator_node.text(org) }
        creator_node.creatorRole { creator_node.text('Producing Organization') }
      end
    end

    # # Spatial Coverage
    # self.spatial_coverage.to_a.each do |coverage|
    #   xml.pbcoreCoverage do |creator_node|
    #     creator_node.coverage(source:'Wikipedia' ref:'http://en.wikipedia.org/wiki/Werowocomoco') { creator_node.text(coverage) }
    #     creator_node.coverageType(source:'PBCore coverageType' ref:'http://pbcore.org/vocabularies/coverageType#spatial') { creator_node.text('Spatial') }
    #   end
    # end
    #
    # # Temporal Coverage
    # self.temporal_coverage.to_a.each do |coverage|
    #   xml.pbcoreCoverage do |creator_node|
    #     creator_node.coverage(source: 'Wikipedia' ref: 'http://en.wikipedia.org/wiki/Werowocomoco') { creator_node.text(coverage) }
    #     creator_node.coverageType(source: 'PBCore coverageType' ref: 'http://pbcore.org/vocabularies/coverageType#spatial') { creator_node.text('Temporal') }
    #   end
    # end

    # Audience level
    self.audience_level.to_a.each { |aud_level| xml.pbcoreAudienceLevel { xml.text(aud_level) } }

    # Audience Rating
    self.audience_rating.to_a.each { |aud_rating| xml.pbcoreAudienceRating { xml.text(aud_rating) } }

    # Anotations
    self.annotation.to_a.each { |annotation| xml.pbcoreAnnotation { xml.text(annotation) } }


    # Rights Summary
    self.rights_summary.to_a.each { |rights_summary| xml.rightsSummary { xml.text(rights_summary) } }


    # EIDR ID
    self.eidr_id.to_a.each { |local_identifier| xml.pbcoreIdentifier(source: 'EIDR') { xml.text(eidr_id) } }


    # local_identifier
    self.local_identifier.to_a.each { |local_identifier| xml.pbcoreIdentifier(source: 'Local Identifier') { xml.text(local_identifier) } }


    # Subject
    self.subject.to_a.each { |subject| xml.pbcoreSubject { xml.text(subject) } }


    # Contributor
    self.find_child(Contribution).each do |contribution|
      xml.pbcoreContributor do |creator_node|
        creator_node.creator { creator_node.text(contribution.contributor.first) }
        creator_node.creatorRole { creator_node.text(contribution.contributor_role.first) }
      end
    end


  end

  def prepare_instantiation(xml)
    self.find_child(PhysicalInstantiation).each do |instantiation|
      prepare_physical_instantiation(xml,instantiation) # separate method to put child nodes for the physical instantiation
    end
    self.find_child(DigitalInstantiation).each do |instantiation|
      prepare_digital_instantiation(xml,instantiation) # separate method to put child nodes for the physical instantiation
    end
  end

  def prepare_physical_instantiation(xml,instantiation)
    xml.pbcoreInstantiation do |instantiation_node|
      instantiation_node.instantiationIdentifier(source: 'Local Instantiation Identifier') { instantiation_node.text('6661-1') } # we can loop on real data to create multiple
      instantiation_node.instantiationPhysical { instantiation_node.text('Format: Video Tape; TypeMaterial: Viewing copy; TechCode: Video home system; Gauge: 1/2 in.') }
      instantiation_node.instantiationLocation { instantiation_node.text('Vault Site: Washington University Film and Media Archive (West Campus); RackNo: VHS.3822') }
      instantiation_node.instantiationMediaType { instantiation_node.text('Moving Image') }
      instantiation_node.instantiationGenerations { instantiation_node.text('Category: Reference copy') }
      instantiation_node.instantiationLanguage { instantiation_node.text('English') }
      instantiation_node.instantiationAnnotation(annotationType: 'organization') { instantiation_node.text('Film & Media Archive, Washington University in St. Louis') }
      # Prepare Essence Track node
      instantiation.find_child(EssenceTrack).each do |essence_track|
        prepare_essence_track(instantiation_node,essence_track)
      end
    end
  end

  def prepare_digital_instantiation(xml,instantiation)
    xml.pbcoreInstantiation do |instantiation_node|
      instantiation_node.instantiationIdentifier { instantiation_node.text('cpb-aacip-151-sn00z71m54.mp4.mp4') } # we can loop on real data to create multiple
      instantiation_node.instantiationDate { instantiation_node.text('1903-12-31') }
      instantiation_node.instantiationDigital { instantiation_node.text('video/mp4') }
      instantiation_node.instantiationStandard { instantiation_node.text('Base Media') }
      instantiation_node.instantiationLocation { instantiation_node.text('N/A') }
      instantiation_node.instantiationMediaType { instantiation_node.text('Moving Image') }
      instantiation_node.instantiationGenerations { instantiation_node.text('Proxy') }
      instantiation_node.instantiationFileSize(unitsOfMeasure: 'MiB') { instantiation_node.text('369') }
      instantiation_node.instantiationDataRate(unitsOfMeasure: 'kb/s') { instantiation_node.text('870') }
      instantiation_node.instantiationTracks { instantiation_node.text('1 video, 1 audio') }
      instantiation_node.instantiationChannelConfiguration { instantiation_node.text('2 channel') }
      # Prepare Essence Track node
      instantiation.find_child(EssenceTrack).each do |essence_track|
        prepare_essence_track(instantiation_node,essence_track)
      end
    end
  end

  def prepare_essence_track(instantiation_node,essence_track)
    instantiation_node.instantiationEssenceTrack do |essence_track_node|
      essence_track_node.essenceTrackType { essence_track_node.text(essence_track.track_type) }

      essence_track.track_id.to_a.each { |track_id| essence_track_node.essenceTrackIdentifier { essence_track_node.text(track_id) } }

      essence_track_node.essenceTrackEncoding { essence_track_node.text(essence_track.encoding) } if essence_track.encoding
      essence_track_node.essenceTrackFrameRate { essence_track_node.text(essence_track.frame_rate) } if essence_track.frame_rate
      essence_track_node.essenceTrackBitDepth { essence_track_node.text(essence_track.bit_depth) } if essence_track.bit_depth
      essence_track_node.essenceTrackAspectRatio { essence_track_node.text(essence_track.aspect_ratio) } if essence_track.aspect_ratio
      essence_track_node.essenceTrackDuration { essence_track_node.text(essence_track.duration) } if essence_track.duration
      essence_track_node.essenceTrackDataRate { essence_track_node.text(essence_track.data_rate) } if essence_track.data_rate
      #TODO: FrameSize Missing?
      essence_track.language.to_a.each { |lang| essence_track_node.essenceTrackLanguage { essence_track_node.text(lang) } }
      essence_track.annotation.to_a.each { |lang| essence_track_node.essenceTrackAnnotation { essence_track_node.text(annotation) } }


    end
  end
end
