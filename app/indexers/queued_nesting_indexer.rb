# frozen_string_literal: true

module QueuedNestingIndexer
  def reindex_relationships(id:, maximum_nesting_depth: configuration.maximum_nesting_depth, extent:)
    if extent.match("queue")
      Rails.logger.info("nested indexing queued")
      Redis.current.zadd("nested:index:#{extent.delete("queue")}", 0, id.to_s)
    else
      ::Samvera::NestingIndexer.reindex_relationships(id: id, extent: 'full')
    end
    true
  end
end
