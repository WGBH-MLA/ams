class Push < ApplicationRecord
  # push to aapb
  belongs_to :user

  validate do
    errors.add(:user, "is required") unless user.is_a? User
    missing_ids = ids_not_found
    errors.add(:pushed_id_csv, "The following IDs are not found in the repository: #{missing_ids.join(', ')}") unless missing_ids.empty?
    validate_status
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

    def validate_status
      invalid_docs = export_search.solr_documents.reject do |doc|
        doc.validation_status_for_aapb == [AssetResource::VALIDATION_STATUSES[:valid]]
      end
      return if invalid_docs.blank?

      AssetResource::VALIDATION_STATUSES.each_pair do |status_key, status_value|
        next if status_key == :valid
        add_status_error(invalid_docs, status_value)
      end
    end

    def add_status_error(invalid_docs, status)
      ids_matching_status = if status == AssetResource::VALIDATION_STATUSES[:empty]
                              invalid_docs.select { |doc| doc.validation_status_for_aapb.blank? }.map(&:id)
                            else
                              invalid_docs.select { |doc| doc.validation_status_for_aapb.include?(status) }.map(&:id)
                            end

      # Prevents adding errors to docs that don't have a value
      # in :validation_status_for_aapb, including all non-AssetResources.
      return if ids_matching_status.blank?

      errors.add(:pushed_id_csv, "The following IDs are #{status}: #{ids_matching_status.join(', ')}")
    end

    # NOTE: do not memoize
    # @return [AMS::Export::Search::CombinedIDSearch] instance used for performing
    #   search and returning solr document results.
    def export_search
      AMS::Export::Search::CombinedIDSearch.new(ids: push_ids, user: user)
    end
end
