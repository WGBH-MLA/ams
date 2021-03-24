class Push < ApplicationRecord
  # push to aapb
  belongs_to :user

  validate do
    errors.add(:user, "is required") unless user.is_a? User
    missing_ids = ids_not_found
    errors.add(:pushed_id_csv, "The following IDs are not found in the repository: #{missing_ids.join(', ')}") unless missing_ids.empty?
  end

  # NOTE: do not memoize
  # TODO: we could just use a serialized field for push_ids rather than manually
  # converting it to CSV and back again. Would require migration of course.
  def push_ids
    pushed_id_csv.to_s.split(',')
  end

  private

    # NOTE: do not memoize
    def found_ids
      export_search.solr_documents.map(&:id)
    end

    # NOTE: do not memoize
    def ids_not_found
      push_ids - found_ids
    end

    # NOTE: do not memoize
    # @return [AMS::Export::Search::CombinedIDSearch] instance used for performing
    #   search and returning solr document results.
    def export_search
      AMS::Export::Search::CombinedIDSearch.new(ids: push_ids, user: user)
    end
end
