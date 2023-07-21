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
      write_all_asset_ids_to_file

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
        processed_file = File.open(PROCESSED_IDS_PATH, 'a+')
        ids.each do |id|
          logger.info("Starting ID: #{id}")
          backfill_validation_status(id)
          # FIXME: not writing properly
          processed_file.write(id)
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
    end

    def write_all_asset_ids_to_file
      resp = ActiveFedora::SolrService.get('has_model_ssim:Asset', fl: [:id], rows: 2_147_483_647)
      raise StandardError, 'No Assets found in Solr' if resp.dig('response', 'docs').blank?

      @ids = resp.dig('response', 'docs').map { |doc| doc['id'] }
      File.open(ALL_IDS_PATH, 'w') do |file|
        file.puts(@ids.join("\n"))
      end
    end

    def setup_remaining_ids_file
      all_ids = Set.new(File.read(ALL_IDS_PATH).split("\n"))
      processed_ids = Set.new(File.read(PROCESSED_IDS_PATH).split("\n"))
      remaining_ids = all_ids.subtract(processed_ids)
      @ids = remaining_ids.to_a

      File.open(REMAINING_IDS_PATH, 'w') do |file|
        file.puts(@ids.join("\n"))
      end
    end

    def setup_working_directory
      FileUtils.mkdir_p(WORKING_DIR)
    end
  end
end
