# Module AMS::PbcoreXmlExportExtension
# This module is an extension of blacklight to export the record in PBCore XML format
module AMS::PbcoreXmlExportExtension
  def self.extended(document)
    document.will_export_as(:pbcore, "application/xml")
  end

  def export_as_pbcore
    pbcore_xml_builder.to_xml # Return PBCore XML
  end

  private

  def pbcore_xml_builder
    Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
      xml.pbcoreDescriptionDocument('xmlns' => 'http://www.pbcore.org/PBCore/PBCoreNamespace.html',
                                    'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
                                    'xsi:schemaLocation' => 'http://www.pbcore.org/PBCore/PBCoreNamespace.html http://www.pbcore.org/xsd/pbcore-2.1.xsd') do
        # Add asset information on the root node of the XML
        prepare_asset(xml)
      end
    end
  end

  # Helper method to add nodes for array fields
  def add_xml_nodes(xml, field_values, node_name, attributes = {}, &block)
    return if field_values.blank?

    field_values&.to_a&.reject(&:blank?)&.each do |value|
      if block_given?
        xml.send(node_name, attributes) { block.call(xml, value) }
      else
        xml.send(node_name, attributes) { xml.text(value) }
      end
    end
  end

  def prepare_asset(xml)
    # Asset Type
    add_xml_nodes(xml, asset_types, :pbcoreAssetType)

    # Dates with types
    date_types = {
        created_date => 'Created',
        broadcast_date => 'Broadcast',
        copyright_date => 'Copyright'
    }

    date_types.each do |dates, type|
      add_xml_nodes(xml, dates, :pbcoreAssetDate, dateType: type)
    end

    # Dates without type
    add_xml_nodes(xml, self.date, :pbcoreAssetDate)

    # Identifiers
    identifier_sources = {
        pbs_nola_code => 'NOLA Code',
        sonyci_id => 'Sony Ci',
        eidr_id => 'EIDR',
        local_identifier => 'Local Identifier'
    }

    identifier_sources.each do |ids, source|
      add_xml_nodes(xml, ids, :pbcoreIdentifier, source: source)
    end

    # Add the main identifier
    xml.pbcoreIdentifier(source: 'http://americanarchiveinventory.org') { xml.text(id) }

    # Titles
    add_xml_nodes(xml, self['title_tesim'], :pbcoreTitle)

    title_types = {
        series_title => 'Series',
        program_title => 'Program',
        episode_title => 'Episode',
        episode_number => 'Episode Number',
        segment_title => 'Segment',
        clip_title => 'Clip',
        promo_title => 'Promo',
        raw_footage_title => 'Raw Footage'
    }

    title_types.each do |titles, type|
      add_xml_nodes(xml, titles, :pbcoreTitle, titleType: type)
    end

    # Subject
    add_xml_nodes(xml, subject, :pbcoreSubject)

    # Descriptions
    add_xml_nodes(xml, self['description_tesim'], :pbcoreDescription)

    description_types = {
        series_description => 'Series',
        program_description => 'Program',
        episode_description => 'Episode',
        segment_description => 'Segment',
        clip_description => 'Clip',
        promo_description => 'Promo',
        raw_footage_description => 'Raw Footage',
        rundown_description => 'Rundown'
    }

    description_types.each do |descriptions, type|
      add_xml_nodes(xml, descriptions, :pbcoreDescription, descriptionType: type)
    end

    # Genre
    add_xml_nodes(xml, genre, :pbcoreGenre, source: 'AAPB Format Genre', annotation: 'genre')

    # Topic
    add_xml_nodes(xml, topics, :pbcoreGenre, source: 'AAPB Topical Genre', annotation: 'topic')

    # Coverage
    add_coverage(xml, spatial_coverage, 'Spatial')
    add_coverage(xml, temporal_coverage, 'Temporal')

    # Audience
    add_xml_nodes(xml, audience_level, :pbcoreAudienceLevel)
    add_xml_nodes(xml, audience_rating, :pbcoreAudienceRating)

    # Producing Organization
    add_xml_nodes(xml, producing_organization, :pbcoreCreator) do |creator_node, org|
      creator_node.creator { creator_node.text(org) }
      creator_node.creatorRole { creator_node.text('Producing Organization') }
    end

    # Contributors
    add_contributions(xml)

    # Rights
    add_rights_summary(xml, rights_summary)
    add_rights_link(xml, rights_link)

    # Instantiations
    prepare_instantiations(xml)

    # Annotations
    add_xml_nodes(xml, annotation, :pbcoreAnnotation) do |node, text|
      node.cdata(text)
    end

    prepare_annotations(xml)
  end

  def add_coverage(xml, coverage_values, coverage_type)
    add_xml_nodes(xml, coverage_values, :pbcoreCoverage) do |node, coverage|
      node.coverage { node.text(coverage) }
      node.coverageType { node.text(coverage_type) }
    end
  end

  def add_contributions(xml)
    members(only: Contribution).each do |contribution|
      xml.pbcoreContributor do |contributor_node|
        contributor_attrs = {}
        contributor_attrs[:annotation] = contribution.annotation.first if contribution.annotation.present? && contribution.annotation.first.present?
        contributor_attrs[:affiliation] = contribution.affiliation.first if contribution.affiliation.present? && contribution.affiliation.first.present?
        contributor_attrs[:affiliation_annotation] = contribution.affiliation_annotation.first if contribution.affiliation_annotation.present? && contribution.affiliation_annotation.first.present?
        contributor_attrs[:start_time] = contribution.start_time.first if contribution.start_time.present? && contribution.start_time.first.present?
        contributor_attrs[:end_time] = contribution.end_time.first if contribution.end_time.present? && contribution.end_time.first.present?
        contributor_attrs[:time_annotation] = contribution.time_annotation.first if contribution.time_annotation.present? && contribution.time_annotation.first.present?

        contributor_node.contributor(contributor_attrs) do
          contributor_node.text(contribution&.contributor&.first)
        end

        if contribution.contributor_role.present?
          role_attrs = {}
          role_attrs[:portrayal] = contribution.portrayal.first if contribution.portrayal.present? && contribution.portrayal.first.present?

          contributor_node.contributorRole(role_attrs) do
            contributor_node.text(contribution&.contributor_role&.first)
          end
        end
      end
    end
  end

  def add_rights_summary(xml, rights_values)
    add_xml_nodes(xml, rights_values, :pbcoreRightsSummary) do |node, summary|
      node.rightsSummary { xml.cdata(summary) }
    end
  end

  def add_rights_link(xml, link_values)
    add_xml_nodes(xml, link_values, :pbcoreRightsSummary) do |node, link|
      node.rightsLink { xml.cdata(link) }
    end
  end

  def prepare_instantiations(xml)
    members(only: PhysicalInstantiation).each do |instantiation|
      prepare_instantiation(xml, instantiation, :physical)
    end

    members(only: DigitalInstantiation).each do |instantiation|
      prepare_instantiation(xml, instantiation, :digital)
    end
  end

  def prepare_instantiation(xml, instantiation, type)
    xml.pbcoreInstantiation do |instantiation_node|
      # Common identifier fields
      if type == :physical
        instantiation_node.instantiationIdentifier(source: 'Filename') { instantiation_node.text(instantiation.id) }
      else
        instantiation_node.instantiationIdentifier { instantiation_node.text(instantiation.id) }
      end

      add_xml_nodes(instantiation_node, instantiation.local_instantiation_identifier, :instantiationIdentifier)

      # Add MD5 and FileSize for digital only
      if type == :digital
        add_xml_nodes(instantiation_node, instantiation.md5, :instantiationIdentifier, source: 'md5')
      end

      # Dates
      add_xml_nodes(instantiation_node, instantiation.date, :instantiationDate)
      add_xml_nodes(instantiation_node, instantiation.digitization_date, :instantiationDate, dateType: 'digitized')

      # Dimensions
      if type == :digital
        add_xml_nodes(instantiation_node, instantiation.dimensions, :instantiationDimensions, unitsOfMeasure: '')
      else
        add_xml_nodes(instantiation_node, instantiation.dimensions, :instantiationDimensions)
      end

      # Format based on type
      if type == :physical
        add_xml_nodes(instantiation_node, instantiation.format, :instantiationPhysical)
      else
        add_xml_nodes(instantiation_node, instantiation.digital_format, :instantiationDigital)
      end

      # Common fields 1
      common_fields_1 = {
          standard: :instantiationStandard,
          location: :instantiationLocation,
          media_type: :instantiationMediaType,
          generations: :instantiationGenerations
      }
      common_fields_1.each do |field, node_name|
        add_xml_nodes(instantiation_node, instantiation.send(field), node_name)
      end
      # Required for proper PBcore ordering
      if type == :digital
        add_xml_nodes(instantiation_node, instantiation.file_size, :instantiationFileSize)
      end
      # Common fields 2
      common_fields_2 = {
          time_start: :instantiationTimeStart,
          duration: :instantiationDuration,
          colors: :instantiationColors,
          tracks: :instantiationTracks,
          channel_configuration: :instantiationChannelConfiguration,
          language: :instantiationLanguage,
          alternative_modes: :instantiationAlternativeModes
      }

      common_fields_2.each do |field, node_name|
        add_xml_nodes(instantiation_node, instantiation.send(field), node_name)
      end

      # Essence Tracks
      instantiation.members(only: EssenceTrack).each do |essence_track|
        prepare_essence_track(instantiation_node, essence_track)
      end

      # Rights
      instantiation_rights(instantiation_node, instantiation.rights_summary, instantiation.rights_link)

      # Annotations
      add_xml_nodes(instantiation_node, instantiation.annotation, :instantiationAnnotation) do |node, annTxt|
        node.cdata(annTxt)
      end

      add_xml_nodes(instantiation_node, instantiation.holding_organization, :instantiationAnnotation, annotationType: 'organization')
      add_xml_nodes(instantiation_node, instantiation.aapb_preservation_lto, :instantiationAnnotation, annotationType: 'preservation LTO')
      add_xml_nodes(instantiation_node, instantiation.aapb_preservation_disk, :instantiationAnnotation, annotationType: 'preservation disk')
    end
  end

  def instantiation_rights(node, rights_summary, rights_link)
    # Rights Summary
    rights_summary&.to_a&.reject(&:blank?)&.each do |summary|
      node.instantiationRights do |rights_node|
        rights_node.rightsSummary { node.cdata(summary) }
      end
    end

    # Rights Link
    rights_link&.to_a&.reject(&:blank?)&.each do |link|
      node.instantiationRights do |rights_node|
        rights_node.rightsLink { node.cdata(link) }
      end
    end
  end

  def prepare_essence_track(instantiation_node, essence_track)
    instantiation_node.instantiationEssenceTrack do |essence_track_node|
      # Track type - simple field but needs to be handled specially as it's the first required field
      add_xml_nodes(essence_track_node, essence_track.track_type, :essenceTrackType)

      # Track ID
      add_xml_nodes(essence_track_node, essence_track.track_id, :essenceTrackIdentifier)

      # Simple fields 1
      add_xml_nodes(essence_track_node, essence_track.standard, :essenceTrackStandard)
      add_xml_nodes(essence_track_node, essence_track.encoding, :essenceTrackEncoding)

      # Fields with units
      add_xml_nodes(essence_track_node, essence_track.data_rate, :essenceTrackDataRate, unitsOfMeasure: 'kb/s')

      # Rate fields
      add_xml_nodes(essence_track_node, essence_track.frame_rate, :essenceTrackFrameRate)
      if essence_track.playback_speed&.any?(&:present?)
        add_xml_nodes(essence_track_node, [essence_track.playback_speed], :essenceTrackPlaybackSpeed,
                      unitsOfMeasure: essence_track.playback_speed_units)
      end
      add_xml_nodes(essence_track_node, essence_track.sample_rate, :essenceTrackSamplingRate)
      add_xml_nodes(essence_track_node, essence_track.bit_depth, :essenceTrackBitDepth)

      # Frame size (needs both width and height)
      if essence_track.frame_width&.any?(&:present?) && essence_track.frame_height&.any?(&:present?)
        frame_size = ["#{essence_track.frame_width} x #{essence_track.frame_height}"]
        add_xml_nodes(essence_track_node, frame_size, :essenceTrackFrameSize)
      end

      # Simple fields 2
      add_xml_nodes(essence_track_node, essence_track.aspect_ratio, :essenceTrackAspectRatio)
      add_xml_nodes(essence_track_node, essence_track.time_start, :essenceTrackTimeStart)
      add_xml_nodes(essence_track_node, essence_track.duration, :essenceTrackDuration)

      # Arrays for language and annotation
      add_xml_nodes(essence_track_node, essence_track.language, :essenceTrackLanguage)
      add_xml_nodes(essence_track_node, essence_track.annotation, :essenceTrackAnnotation)
    end
  end

  def prepare_annotations(xml)
    return if annotations.blank?

    annotations.each do |annotation|
      attributes = {
        ref: annotation.ref,
        source: annotation.source,
        annotation: annotation.annotation,
        version: annotation.version
      }
      # Only add annotationType if present
      if annotation.annotation_type.present?
        attributes[:annotationType] = AnnotationTypesService.new.label(annotation.annotation_type)
      end
      xml.pbcoreAnnotation(attributes) { xml.text(annotation.value) }
    end
  end
end
