# frozen_string_literal: true
if ENV['SETTINGS__BULKRAX__ENABLED'] == 'true'
  # rubocop:disable Metrics/BlockLength
  Bulkrax.setup do |config|
    # Add local parsers
    config.parsers = [
      {
        name: 'AAPB CSV',
        class_name: 'CsvParser',
        partial: 'csv_fields'
      },
      # overridding the xml parser to remove the 'multiple' import_type option,
      # as this app currently does not support it
      {
        name: 'AAPB PBCore XML',
        class_name: 'PbcoreXmlParser',
        partial: 'pbcore_xml_fields_override'
      },
      {
        name: 'AAPB PBCore XML/Manifest',
        class_name: 'PbcoreManifestParser',
        partial: 'pbcore_manifest_xml_fields_override'
      }
    ]

    def headers(term = nil)
      cc = [Asset, Contribution, DigitalInstantiation, EssenceTrack, PhysicalInstantiation]
      properties = []

      cc.each { |model| properties << "#{model}.#{term}" }

      properties
    end

    config.fill_in_blank_source_identifiers = ->(type, index, key_count) { "#{type}-#{index}-#{key_count}" }

    config.field_mappings['CsvParser'] = {
      'admin_data_gid' => { from: headers('admin_data_gid') },
      'affiliation' => { from: 'Contributor.affiliation' },
      'alternative_modes' => { from: headers('alternative_modes'), split: true, join: true },
      'annotation' => { from: headers('annotation'), split: true, join: true },
      'aspect_ratio' => { from: ["EssenceTrack.aspect_ratio"] },
      'asset_types' => { from: headers('asset_types'), split: true, join: true },
      'audience_level' => { from: headers('audience_level'), split: true, join: true },
      'audience_rating' => { from: headers('audience_rating'), split: true, join: true },
      'based_near' => { from: headers('based_near'), split: true, join: true },
      'bibliographic_citation' => { from: headers('bibliographic_citation'), split: true, join: true },
      'bit_depth' => { from: ["EssenceTrack.bit_depth"] },
      'broadcast_date' => { from: headers('broadcast_date'), split: true, join: true },
      'bulkrax_identifier' => { from: ['bulkrax_identifier'], source_identifier: true },
      'channel_configuration' => { from: headers('channel_configuration') },
      'clip_description' => { from: headers('clip_description'), split: true, join: true },
      'clip_title' => { from: headers('clip_title') },
      'colors' => { from: headers('colors') },
      'contributor' => { from: headers('contributor'), split: true, join: true },
      'contributor_role' => { from: 'Contributor.contributor_role' },
      'copyright_date' => { from: headers('copyright_date'), split: true, join: true },
      'creator' => { from: headers('creator'), split: true, join: true },
      'data_rate' => { from: headers('data_rate') },
      'date' => { from: headers('date'), split: true, join: true },
      'date_created' => { from: headers('date_created'), split: true, join: true },
      'description' => { from: headers('description'), split: true, join: true },
      'digital_format' => { from: ["DigitalInstantiation.digital_format"] },
      'digitization_date' => { from: 'PhysicalInstantiation.digitization_date' },
      'dimensions' => { from: headers('dimensions'), split: true, join: true },
      'duration' => { from: headers('duration') },
      'eidr_id' => { from: headers('eidr_id'), split: true, join: true },
      'embargo_id' => { from: headers('embargo_id') },
      'encoding' => { from: ["EssenceTrack.encoding"] },
      'episode_description' => { from: headers('episode_description'), split: true, join: true },
      'episode_number' => { from: headers('episode_number'), split: true, join: true },
      'episode_title' => { from: headers('episode_title') },
      'file' => { from: headers('file'), split: true, join: true },
      'file_size' => { from: ["DigitalInstantiation.file_size"] },
      'format' => { from: 'PhysicalInstantiation.format' },
      'frame_height' => { from: ["EssenceTrack.frame_height"] },
      'frame_rate' => { from: ["EssenceTrack.frame_rate"] },
      'frame_width' => { from: ["EssenceTrack.frame_width"] },
      'generations' => { from: headers('generations'), split: true, join: true },
      'genre' => { from: headers('genre'), split: true, join: true },
      'holding_organization' => { from: headers('holding_organization'), split: true, join: true },
      'id' => { from: headers('id') },
      'identifier' => { from: headers('identifier'), split: true, join: true },
      'instantiation_admin_data_gid' => { from: headers('instantiation_admin_data_gid') },
      'keyword' => { from: headers('keyword'), split: true, join: true },
      'language' => { from: headers('language'), split: true, join: true },
      'lease_id' => { from: headers('lease_id') },
      'license' => { from: headers('license'), split: true, join: true },
      'local_identifier' => { from: headers('local_identifier'), split: true, join: true },
      'local_instantiation_identifier' => { from: headers('local_instantiation_identifier'), split: true, join: true },
      'location' => { from: headers('location') },
      'media_type' => { from: headers('media_type') },
      'pbs_nola_code' => { from: headers('pbs_nola_code'), split: true, join: true },
      'playback_speed' => { from: ["EssenceTrack.playback_speed"] },
      'playback_speed_units' => { from: ["EssenceTrack.playback_speed_units"] },
      'portrayal' => { from: 'Contributor.portrayal' },
      'producing_organization' => { from: headers('producing_organization'), split: true, join: true },
      'program_description' => { from: headers('program_description'), split: true, join: true },
      'program_title' => { from: headers('program_title') },
      'promo_description' => { from: headers('promo_description'), split: true, join: true },
      'promo_title' => { from: headers('promo_title') },
      'publisher' => { from: headers('publisher'), split: true, join: true },
      'raw_footage_description' => { from: headers('raw_footage_description'), split: true, join: true },
      'raw_footage_title' => { from: headers('raw_footage_title') },
      'related_url' => { from: headers('related_url'), split: true, join: true },
      'rendering_ids' => { from: headers('rendering_ids') },
      'representative_id' => { from: headers('representative_id') },
      'resource_type' => { from: headers('resource_type'), split: true, join: true },
      'rights_link' => { from: headers('rights_link'), split: true, join: true },
      'rights_statement' => { from: headers('rights_statement'), split: true, join: true },
      'rights_summary' => { from: headers('rights_summary'), split: true, join: true },
      'sample_rate' => { from: ["EssenceTrack.sample_rate"] },
      'segment_description' => { from: headers('segment_description'), split: true, join: true },
      'segment_title' => { from: headers('segment_title') },
      'series_description' => { from: headers('series_description'), split: true, join: true },
      'series_title' => { from: headers('series_title') },
      'source' => { from: headers('source'), split: true, join: true },
      'spatial_coverage' => { from: headers('spatial_coverage'), split: true, join: true },
      'standard' => { from: headers('standard') },
      'subject' => { from: headers('subject'), split: true, join: true },
      'temporal_coverage' => { from: headers('temporal_coverage'), split: true, join: true },
      'thumbnail_id' => { from: headers('thumbnail_id') },
      'time_start' => { from: headers('time_start') },
      'title' => { from: headers('title') },
      'topics' => { from: headers('topics'), split: true, join: true },
      'track_id' => { from: ["EssenceTrack.track_id"] },
      'track_type' => { from: ["EssenceTrack.track_type"] },
      'tracks' => { from: headers('tracks') }
    }

    config.field_mappings['PbcoreXmlParser'] = {
      'bulkrax_identifier' => { from: ['pbcoreIdentifier'], source_identifier: true },
      'dimensions' => { from: headers('dimensions'), split: true, join: true },
      'media_type' => { from: headers('media_type'), split: true, join: true }
    }

    config.field_mappings['PbcoreManifestParser'] = {
      'bulkrax_identifier' => { from: ['instantiationIdentifier'], source_identifier: true },
      'dimensions' => { from: headers('dimensions'), split: true, join: true },
      'generations' => { from: ['DigitalInstantiation.generations'] },
      'holding_organization' => { from: ['DigitalInstantiation.holding_organization'] },
      'media_type' => { from: headers('media_type'), split: true, join: true }
    }

    # WorkType to use as the default if none is specified in the import
    # Default is the first returned by Hyrax.config.curation_concerns
    # config.default_work_type = MyWork

    # Path to store pending imports
    # config.import_path = 'tmp/imports'

    # Path to store exports before download
    # config.export_path = 'tmp/exports'

    # Server name for oai request header
    # config.server_name = 'my_server@name.com'

    # Field_mapping for establishing a parent-child relationship (FROM parent TO child)
    # This can be a Collection to Work, or Work to Work relationship
    # This value IS NOT used for OAI, so setting the OAI Entries here will have no effect
    # The mapping is supplied per Entry, provide the full class name as a string, eg. 'Bulkrax::CsvEntry'
    # Example:
    #   {
    #     'Bulkrax::RdfEntry'  => 'http://opaquenamespace.org/ns/contents',
    #     'Bulkrax::CsvEntry'  => 'children'
    #   }
    # By default no parent-child relationships are added
    # config.parent_child_field_mapping = { }

    # Field_mapping for establishing a collection relationship (FROM work TO collection)
    # This value IS NOT used for OAI, so setting the OAI parser here will have no effect
    # The mapping is supplied per Entry, provide the full class name as a string, eg. 'Bulkrax::CsvEntry'
    # The default value for CSV is collection
    # Add/replace parsers, for example:
    # config.collection_field_mapping['Bulkrax::RdfEntry'] = 'http://opaquenamespace.org/ns/set'

    # Field mappings
    # Create a completely new set of mappings by replacing the whole set as follows
    #   config.field_mappings = {
    #     "Bulkrax::OaiDcParser" => { **individual field mappings go here*** }
    #   }
    # Add to, or change existing mappings as follows
    #   e.g. to exclude date
    #   config.field_mappings["Bulkrax::OaiDcParser"]["date"] = { from: ["date"], excluded: true  }
    #
    #   e.g. to add the required source_identifier field
    #   config.field_mappings["Bulkrax::CsvParser"]["source_id"] = { from: ["old_source_id"], source_identifier: true  }
    # If you want Bulkrax to fill in source_identifiers for you, see below

    # To duplicate a set of mappings from one parser to another
    #   config.field_mappings["Bulkrax::OaiOmekaParser"] = {}
    #   config.field_mappings["Bulkrax::OaiDcParser"].each |key,value| do
    #     config.field_mappings["Bulkrax::OaiOmekaParser"][key] = value
    #   end

    # Should Bulkrax make up source identifiers for you? This allow round tripping
    # and download errored entries to still work, but does mean if you upload the
    # same source record in two different files you WILL get duplicates.
    # It is given two aruguments, self at the time of call and the index of the reocrd
    #    config.fill_in_blank_source_identifiers = ->(parser, index) { "b-#{parser.importer.id}-#{index}"}
    # or use a uuid
    #    config.fill_in_blank_source_identifiers = ->(parser, index) { SecureRandom.uuid }

    # Properties that should not be used in imports/exports. They are reserved for use by Hyrax.
    # config.reserved_properties += ['my_field']
  end
end
# rubocop:enable Metrics/BlockLength

# # Sidebar for hyrax 3+ support
#   if Object.const_defined?(:Hyrax) && ::Hyrax::DashboardController&.respond_to?(:sidebar_partials)
#     path = "hyrax/dashboard/sidebar/bulkrax_sidebar_additions"
#     Hyrax::DashboardController.sidebar_partials[:repository_content] << path
#   end
