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
      # TODO:
      # - Figure out intended child record count from original data source
      #   - Can probably be found on a record's corresponding Bulkrax::Entry or BatchItem
      #   - Set value to :intended_children_count
      # - Figure out current validation status
      #   - @see AssetActor#set_validation_status
      #   - Set controlled value to :validation_status_for_aapb
      # TODO: handle when source data can't be found (possible?)
      # Possible way to get data from Asset ingested by a BatchIngester:
      # File.read(@batch_item.source_location)
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
