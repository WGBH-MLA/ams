require 'ams'


# only query for default and import queues - ignore all others
namespace :ams do
  desc 'Resets Fedora, Solr, Database, and creates default admin set'
  task trigger_importer: :environment do
    # queue if an importer is running

    # if not then queue the next importer


    # If using this to determine the next importer to run, you'll need to adjust this
    # query to exclude importers that have errors so that the script doesn't try to re-run those
    remaining_ids = Bulkrax::Importer
      .left_outer_joins(:entries)
      .where('name LIKE ?', 'AMS1Importer_%')
      .where(entries: { id: nil })
      # add removing of jobs with errors
      .order(:id)
      .pluck(:id)



    @imp = Bulkrax::Importer.first
    @imp.statuses.last.status_message

    # If using this to determine the next importer to run, you'll need to adjust this
    # query to exclude importers that have errors so that the script doesn't try to re-run those
    remaining_importers = Bulkrax::Importer
      .left_outer_joins(:entries)
      .where('name LIKE ?', 'AMS1Importer_%')
      .where(entries: { id: nil })
      .order(:id)

    remaining_importers.each do |imp|
      next if imp.statuses.last.status_message
      Bulkrax::Importer.perform_later(imp.id)
    end
  end
end
