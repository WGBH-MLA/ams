# frozen_string_literal: true
if ENV['SETTINGS__BULKRAX__ENABLED'] == 'true'
  Bulkrax.setup do |config|
    # Add local parsers
    config.parsers = [
      { name: 'AAPB CSV', class_name: 'CsvParser', partial: 'csv_fields' },
      # we are overridding the xml parser to remove the 'multiple' import_type option, as this app currently does not support it
      { name: 'AAPB PBCore XML', class_name: 'PbcoreXmlParser', partial: 'pbcore_xml_fields_override'},
      { name: 'AAPB PBCore XML/Manifest', class_name: 'PbcoreManifestParser', partial: 'pbcore_manifest_xml_fields_override'}
    ]

    def headers(term = nil)
      cc = [Asset, PhysicalInstantiation, Contribution]
      properties = []

      cc.each { |model| properties << "#{model}.#{term}" }

      properties
    end

    # these properties will split on semi-colon (;) or pipe (|)
    standard_csv_mappings = {
      'annotation' => { from: headers('annotation'), split: true },
      'asset_types' => { from: headers('asset_types'), split: true },
      'audience_level' => { from: headers('audience_level'), split: true },
      'audience_rating' => { from: headers('audience_rating'), split: true },
      'based_near' => { from: headers('based_near'), split: true },
      'bibliographic_citation' => { from: headers('bibliographic_citation'), split: true },
      'broadcast_date' => { from: headers('broadcast_date'), split: true },
      'clip_description' => { from: headers('clip_description'), split: true },
      'contributor' => { from: headers('contributor'), split: true },
      'copyright_date' => { from: headers('copyright_date'), split: true },
      'created_date' => { from: headers('created_date'), split: true },
      'creator' => { from: headers('creator'), split: true },
      'date' => { from: headers('date'), split: true },
      'date_created' => { from: headers('date_created'), split: true },
      'description' => { from: headers('description'), split: true },
      'dimensions' => { from: headers('dimensions'), split: true },
      'eidr_id' => { from: headers('eidr_id'), split: true },
      'episode_description' => { from: headers('episode_description'), split: true },
      'episode_number' => { from: headers('episode_number'), split: true },
      'file' => { from: headers('file'), split: true },
      'generations' => { from: headers('generations'), split: true },
      'genre' => { from: headers('genre'), split: true },
      'identifier' => { from: headers('identifier'), split: true },
      'keyword' => { from: headers('keyword'), split: true },
      'language' => { from: headers('language'), split: true },
      'license' => { from: headers('license'), split: true },
      'local_identifier' => { from: headers('local_identifier'), split: true },
      'local_instantiation_identifier' => { from: headers('local_instantiation_identifier'), split: true },
      'pbs_nola_code' => { from: headers('pbs_nola_code'), split: true },
      'producing_organization' => { from: headers('producing_organization'), split: true },
      'program_description' => { from: headers('program_description'), split: true },
      'promo_description' => { from: headers('promo_description'), split: true },
      'publisher' => { from: headers('publisher'), split: true },
      'raw_footage_description' => { from: headers('raw_footage_description'), split: true },
      'related_url' => { from: headers('related_url'), split: true },
      'resource_type' => { from: headers('resource_type'), split: true },
      'rights_link' => { from: headers('rights_link'), split: true },
      'rights_statement' => { from: headers('rights_statement'), split: true },
      'rights_summary' => { from: headers('rights_summary'), split: true },
      'segment_description' => { from: headers('segment_description'), split: true },
      'series_description' => { from: headers('series_description'), split: true },
      'source' => { from: headers('source'), split: true },
      'spatial_coverage' => { from: headers('spatial_coverage'), split: true },
      'subject' => { from: headers('subject'), split: true },
      'temporal_coverage' => { from: headers('temporal_coverage'), split: true },
      'topics' => { from: headers('topics'), split: true },
      'track_id' => { from: headers('track_id'), split: true }
    }


    config.fill_in_blank_source_identifiers = ->(obj, index) { "#{obj.importerexporter.id}-#{index}"}
    config.field_mappings['CsvParser'] = standard_csv_mappings.merge({
      'bulkrax_identifier' => { from: ['bulkrax_identifier'], source_identifier: true },
    })

    config.field_mappings['PbcoreXmlParser'] = {
      'bulkrax_identifier' => { from: ['pbcoreIdentifier'], source_identifier: true }
    }

    config.field_mappings['PbcoreManifestParser'] = {
      'bulkrax_identifier' => { from: ['instantiationIdentifier'], source_identifier: true },
      'generations' => { from: ["DigitalInstantiation.generations"] },
      'holding_organization' => { from: ["DigitalInstantiation.holding_organization"] }
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
    # #   e.g. to add the required source_identifier field
    #   #   config.field_mappings["Bulkrax::CsvParser"]["source_id"] = { from: ["old_source_id"], source_identifier: true  }
    # If you want Bulkrax to fill in source_identifiers for you, see below

    # To duplicate a set of mappings from one parser to another
    #   config.field_mappings["Bulkrax::OaiOmekaParser"] = {}
    #   config.field_mappings["Bulkrax::OaiDcParser"].each {|key,value| config.field_mappings["Bulkrax::OaiOmekaParser"][key] = value }

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

# # Sidebar for hyrax 3+ support
# Hyrax::DashboardController.sidebar_partials[:repository_content] << "hyrax/dashboard/sidebar/bulkrax_sidebar_additions" if Object.const_defined?(:Hyrax) && ::Hyrax::DashboardController&.respond_to?(:sidebar_partials)
