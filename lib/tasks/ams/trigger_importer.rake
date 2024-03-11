require 'ams'


# only query for default and import queues - ignore all others
namespace :ams do
  desc 'Queue importer whenever one is not running'
  task trigger_importer: :environment do
    # check if an importer is running
    active_workers = Sidekiq::Workers.new.map do |_process_id, _thread_id, work|
      work
    end
    return if active_workers.select do |worker|
      worker['queue'] == 'import' || worker['queue'] == 'default'
    end.present?

    # if not then queue the next importer
    remaining_importers = Bulkrax::Importer
      .left_outer_joins(:entries)
      .where('name LIKE ?', 'AMS1Importer_%')
      .where(entries: { id: nil })
      .order(:id)

    imp_without_errors = remaining_importers.reject { |imp|  !imp.statuses.empty? }
    Bulkrax::ImporterJob.perform_later(imp_without_errors.first&.id) unless imp_without_errors.empty?
  end
end
