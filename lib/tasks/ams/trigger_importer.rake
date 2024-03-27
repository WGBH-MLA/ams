# frozen_string_literal: true

require 'ams'

# only query for default and import queues - ignore all others
namespace :ams do
  desc 'Queue importer whenever one is not running'
  task trigger_importer: :environment do
    log_path = Rails.root.join('tmp', 'imports', 'trigger_importer_rake.log')
    FileUtils.touch(log_path)
    log = File.open(log_path, 'a')

    # check if an importer is running
    active_workers = Sidekiq::Workers.new.map do |_process_id, _thread_id, work|
      work
    end
    if active_workers.select { |worker| worker['queue'] == 'import' || worker['queue'] == 'default' }.present?
      log.puts "#{Time.now.getlocal('-07:00').strftime('%Y-%m-%d %H:%M:%S')} - Skipping, importer still running"
      exit 0
    end

    # if not then queue the next importer
    remaining_importers = Bulkrax::Importer
      .left_outer_joins(:entries)
      .where('name LIKE ?', 'AMS1Importer_%')
      .where(entries: { id: nil })
      .order(:id)

    imp_without_errors = remaining_importers.reject { |imp| imp.status == 'Failed' }
    id_to_run = imp_without_errors.first&.id
    if id_to_run.blank?
      log.puts "#{Time.now.getlocal('-07:00').strftime('%Y-%m-%d %H:%M:%S')} - No IDs to run"
      exit 1
    end

    log.puts "#{Time.now.getlocal('-07:00').strftime('%Y-%m-%d %H:%M:%S')} - Starting #{id_to_run}"
    Bulkrax::ImporterJob.perform_later(id_to_run)
  ensure
    log.close
  end
end
