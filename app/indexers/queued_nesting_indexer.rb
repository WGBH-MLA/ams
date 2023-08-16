# frozen_string_literal: true

if App.rails_5_1?
  class QueuedNestingIndexer
    extend Samvera::NestingIndexer
    def self.reindex_relationships(id:, maximum_nesting_depth: nil, extent:)
      if extent.match("queue")
        Rails.logger.info("nested indexing queued")
        Redis.current.zadd("nested:index:#{extent.delete("queue")}", 0, id.to_s)
      else
        ::Samvera::NestingIndexer.reindex_relationships(id: id, extent: 'full')
      end
      true
    end
  end
end
