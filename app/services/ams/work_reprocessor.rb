# frozen_string_literal: true
require 'ruby-progressbar'

# Generic class to create a resumable run through of all the model ids
module AMS
  class WorkReprocessor

    attr_accessor :query, :logger, :working_dir, :all_ids_path, :processed_ids_path, :remaining_ids_path, :failed_ids_path, :logger_path

    def initialize(dir_name: 'all_models')
      @query = "(has_model_ssim:DigitalInstantiationResource OR has_model_ssim:PhysicalInstantiationResource OR has_model_ssim:DigitalInstantiation OR has_model_ssim:PhysicalInstantiation OR has_model_ssim:Asset OR has_model_ssim:AssetResource OR has_model_ssim:EssenceTrack OR has_model_ssim:EssenceTrackResource OR has_model_ssim:Contribution OR has_model_ssim:ContributionResource)"

      @working_dir = Rails.root.join('tmp', 'imports', dir_name)
      @logger_path = working_dir.join('status.log')
      @all_ids_path = working_dir.join('all_ids.txt')
      @processed_ids_path = working_dir.join('processed_ids.txt')
      @remaining_ids_path = working_dir.join('remaining_ids.txt')
      @failed_ids_path = working_dir.join('failed_ids.txt')
      setup_working_directory

      # TODO: replace with tagged logger
      @logger = ActiveSupport::Logger.new(logger_path)
    end

    def fresh_run
      ids = write_ids_to_file
      [processed_ids_path, failed_ids_path].each do |file|
        FileUtils.rm(file) if File.exist?(file)
      end

      run(ids: ids)
    end

    def resume
      msg = 'Run #fresh_run before attempting to resume'
      raise StandardError, msg unless File.exist?(all_ids_path) && File.exist?(processed_ids_path)

      ids = setup_remaining_ids_file

      run(ids: ids)
    end

    ## NOTE:
    # Running this method will result in duplicate IDs being added to the processed_ids_path
    # file. However, while this means that the line count of that file won't match one-to-one
    # with the number of IDs processed, the line count of the failed_ids_path already isn't
    # one-to-one and, more importantly, it won't break the logic in the #setup_remaining_ids_file
    # method, which is the primary purpose of the processed_ids_path file.
    def run_failed
      raise StandardError, 'No failed IDs found' unless File.exist?(failed_ids_path)

      ## NOTE:
      # Since some processing will happen within the BackfillAssetValidationStatusJob,
      # and since failed jobs retry automatically, it is very likely that IDs within
      # the failed_ids_path file will be duplicated several times. Because of this,
      # to avoid duplicate processing, we use Set#uniq and don't fall back on the
      # failed_ids_path file when calling #run.
      failed_ids = Set.new(File.read(failed_ids_path).split("\n"))
      ids = failed_ids.uniq
      run(ids: ids)
    end

    def run(ids:)
      progressbar = ProgressBar.create(total: ids.size, format: '%a %e %P% Processed: %c from %C')

      # Use #begin here to avoid the need to repeatedly open and close the processed_file each time
      # we need to write to it. The #ensure makes sure the file closes properly even if an error arises,
      # preventing any data loss. In addition, it conserves IO processing resources by not continuously
      # opening and closing the file.
      begin
        # Suppress most ActiveRecord logging to be able to clearly see the ProgressBar's progress
        original_log_level = ActiveRecord::Base.logger.level
        ActiveRecord::Base.logger.level = Logger::ERROR

        processed_file = File.open(processed_ids_path, 'a')
        ids.each do |id|
          # This nested #begin lets us log the `id` currently being processed if an error is thrown
          begin # rubocop:disable Style/RedundantBegin
            logger.info("Starting ID: #{id}")
            processed_file.puts(id)
            run_on_id(id)
            progressbar.increment
          rescue => e
            logger.error("#{e.class} | #{e.message} | #{id} | Continuing...")
            File.open(failed_ids_path, 'a') { |file| file.puts(id) }
          end
        end
      ensure
        ActiveRecord::Base.logger.level = original_log_level
        processed_file&.close
      end
    end

    def run_on_id
      raise 'implement in child classes'
    end

    def write_ids_to_file
      row_size = 500_000_000
      offset = 0

      resp = ActiveFedora::SolrService.get(query, fl: [:id], rows: row_size, start: offset)
      docs = resp.dig('response', 'docs')
      ids ||= []

      while(docs.size > 0) do
        ids += resp.dig('response', 'docs').map { |doc| doc['id'] }
        offset += row_size
        resp = ActiveFedora::SolrService.get(query, fl: [:id], rows: row_size, start: offset)
        docs = resp.dig('response', 'docs')
      end

      write_ids_to(ids: ids, path: all_ids_path)
      ids
    end

    def setup_remaining_ids_file
      all_ids = Set.new(File.read(all_ids_path).split("\n"))
      processed_ids = Set.new(File.read(processed_ids_path).split("\n"))
      remaining_ids = all_ids.subtract(processed_ids)
      ids = remaining_ids.to_a

      write_ids_to(ids: ids, path: remaining_ids_path)
    end

    def write_ids_to(ids:, path:)
      File.open(path, 'w') do |file|
        ids.each do |id|
          file.puts(id)
        end
      end
    end

    def setup_working_directory
      FileUtils.mkdir_p(working_dir)
    end
  end
end
