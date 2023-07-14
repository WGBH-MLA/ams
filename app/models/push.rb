class Push < ApplicationRecord
  # push to aapb
  belongs_to :user

  validate do
    errors.add(:user, "is required") unless user.is_a? User
    missing_ids = ids_not_found
    errors.add(:pushed_id_csv, "The following IDs are not found in the repository: #{missing_ids.join(', ')}") unless missing_ids.empty?
    validate_missing_children
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

    # TODO: rename method when :aapb_pushable is used for generic validation
    def validate_missing_children
      # FIXME: switch for cleaner version when :aapb_pushable is indexed as a boolean
      missing_children_ids = export_search.solr_documents.reject { |doc| doc['aapb_pushable_tesim'] == ['true'] }.map(&:id)
      # missing_children_ids = export_search.solr_documents.reject(&:aapb_pushable).map(&:id)
      return if missing_children_ids.blank?

      # TODO: reword error message when :aapb_pushable is used for generic validation
      errors.add(:pushed_id_csv, "The following IDs are missing child records: #{missing_children_ids.join(', ')}")
    end

    # NOTE: do not memoize
    # @return [AMS::Export::Search::CombinedIDSearch] instance used for performing
    #   search and returning solr document results.
    def export_search
      AMS::Export::Search::CombinedIDSearch.new(ids: push_ids, user: user)
    end
end
