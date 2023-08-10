# frozen_string_literal: true
require 'ruby-progressbar'

module AMS
  class BackfillAssetValidationStatus
    WORKING_DIR = Rails.root.join('tmp', 'imports', 'backfill_asset_validation_status').freeze
    ALL_IDS_PATH = WORKING_DIR.join('all_ids.txt').freeze
    PROCESSED_IDS_PATH = WORKING_DIR.join('processed_ids.txt').freeze
    REMAINING_IDS_PATH = WORKING_DIR.join('remaining_ids.txt').freeze

    attr_accessor :ids, :logger

    def initialize
      setup_working_directory
      @logger = ActiveSupport::Logger.new(WORKING_DIR.join('backfill_asset_validation_status.log'))
    end

    def fresh_run
      write_asset_ids_to_file

      run(ids_file: ALL_IDS_PATH)
    end

    def resume
      msg = 'Run #fresh_run before attempting to resume'
      raise StandardError, msg unless File.exist?(ALL_IDS_PATH) && File.exist?(PROCESSED_IDS_PATH)

      setup_remaining_ids_file

      run(ids_file: REMAINING_IDS_PATH)
    end

    def run(ids_file:)
      @ids ||= File.read(ids_file).split("\n")
      progressbar = ProgressBar.create(total: ids.size, format: '%a %e %P% Processed: %c from %C')

      begin
        processed_file = File.open(PROCESSED_IDS_PATH, 'a')
        ids.each do |id|
          logger.info("Starting ID: #{id}")
          backfill_validation_status(id)
          processed_file.puts(id)
          progressbar.increment
        end
      rescue => e
        logger.error("#{e.class} | #{e.message} | #{id} | Continuing...")
      ensure
        processed_file&.close
      end
    end

    private

    def backfill_validation_status(id)
      asset = Asset.find(id)
      attrs_for_actor = {}
      raise StandardError, "Unable to find admin data for Asset #{asset.id}" if asset.admin_data.blank?

      raw_source_data = if asset.admin_data.bulkrax_importer_id.present?
                          raw_data_from_bulkrax_entry(asset.admin_data.bulkrax_importer_id)
                        elsif asset.admin_data.hyrax_batch_ingest_batch_id.present?
                          raw_data_from_batch_item(asset.admin_data.hyrax_batch_ingest_batch_id)
                        else
                          raise StandardError, "Unable to find source data for Asset #{asset.id}"
                        end

      parsed_source_data = AAPB::BatchIngest::PBCoreXMLMapper.new(raw_source_data).asset_attributes
      attrs_for_actor['intended_children_count'] = parsed_source_data[:intended_children_count]
      if attrs_for_actor['intended_children_count'].blank?
        raise StandardError, "Unable to count intended children for Asset #{asset.id}"
      end

      # Generic admin user we can count on existing
      user = User.find_by(email: 'wgbh_admin@wgbh-mla.org')
      actor = Hyrax::CurationConcern.actor
      env = Hyrax::Actors::Environment.new(asset, Ability.new(user), attrs_for_actor)

      actor.update(env)
    end

    def raw_data_from_bulkrax_entry(importer_id)
      importer = Bulkrax::Importer.find(importer_id)
      matching_entries = importer.entries.select(:id).where("JSON_EXTRACT(parsed_metadata, '$.id') = '#{asset.id}'")
      raise StandardError, "Ambiguous data sources found for Asset #{asset.id}" if matching_entries.count > 1

      entry = Bulkrax::Entry.find(matching_entries.first.try(:id))
      ## NOTE:
      # As of 9 August, 2023, all Bulkrax entries in production are instances of Bulkrax::PbcoreXmlEntry, thus
      # we can safely assume that the data we're after won't be anywhere other than in `raw_metadata['pbcore_xml']`
      entry.raw_metadata['pbcore_xml']
    end

    def raw_data_from_batch_item(batch_id)
      batch = Hyrax::BatchIngest::Batch.find(batch_id)
      ## NOTE:
      # As of 9 August, 2023, the logic to count the number of intended children an Asset should have has only
      # been applied to PBCore XML BatchIngests. Once this logic has been applied to other types of ingests
      # (CSV, etc.), this short-circuit should be removed and this class should be modified to extrac the data
      # from more than just PBCore XML.
      # @see https://github.com/scientist-softserv/ams/issues/9
      if batch.ingest_type != 'aapb_pbcore_zipped'
        raise StandardError, "Don't know how to count intended children when BatchIngest type is #{batch.ingest_type}"
      end

      batch_item = batch.batch_items.find_by(repo_object_id: asset.id)
      File.read(batch_item.source_location)
    end

    def write_asset_ids_to_file
      query = 'has_model_ssim:Asset -intended_children_count_isi:[* TO *]'
      max_rows = 2_147_483_647
      resp = ActiveFedora::SolrService.get(query, fl: [:id], rows: max_rows)
      raise StandardError, 'No Assets found in Solr' if resp.dig('response', 'docs').blank?

      @ids = resp.dig('response', 'docs').map { |doc| doc['id'] }
      write_ids_to(ALL_IDS_PATH)
    end

    def setup_remaining_ids_file
      all_ids = Set.new(File.read(ALL_IDS_PATH).split("\n"))
      processed_ids = Set.new(File.read(PROCESSED_IDS_PATH).split("\n"))
      remaining_ids = all_ids.subtract(processed_ids)
      @ids = remaining_ids.to_a

      write_ids_to(REMAINING_IDS_PATH)
    end

    def write_ids_to(path)
      FileUtils.rm(path) if File.exist?(path)

      File.open(path, 'a') do |file|
        ids.each do |id|
          file.puts(id)
        end
      end
    end

    def setup_working_directory
      FileUtils.mkdir_p(WORKING_DIR)
    end
  end
end
