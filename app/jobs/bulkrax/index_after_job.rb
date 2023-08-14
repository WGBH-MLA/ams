# TODO: delete with dual boot cleanup - nested indexing is replaced by graph indexer
module Bulkrax
  class IndexAfterJob < ApplicationJob
    queue_as :import

    def perform(importer)
      # check if importer is done, otherwise reschedule
      pending_num = importer.entries.left_outer_joins(:latest_status)
        .where('bulkrax_statuses.status_message IS NULL ').count
      return reschedule(importer.id) unless pending_num.zero?

      # read queue and index objects
      set = Redis.current.zpopmax("nested:index:#{importer.id}", 100)
      logger.debug(set.to_s)
      return if set.blank?
      loop do
        set.each do |key, score|
          Hyrax.config.nested_relationship_reindexer.call(id: key, extent: 'full')
        end
        set = Redis.current.zpopmax("nested:index:#{importer.id}", 100)
        logger.debug(set.to_s)
        break if set.blank?
      end
    end

    def reschedule(importer_id)
      Bulkrax::IndexAfterJob.set(wait: 1.minutes).perform_later(importer_id: importer_id)
      false
    end
  end
end
