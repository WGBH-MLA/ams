class Push < ApplicationRecord
  # push to aapb
  belongs_to :user
  has_many :published_assets

  serialize :asset_ids_queue, type: Array, coder: JSON

  enum status: {
    initiated: "initiated",
    queueing: "queueing",
    uploading: "uploading",
    finished: "finished"
  }

  validate(
    :validate_user,
    :validate_assets_exist,
    :validate_assets_have_titles,
    :validate_assets_have_descriptions,
    :validate_assets_chilren_validation_status,
    :validate_lua_and_sonyci_id
  )

  private

  def found_docs
    @found_docs ||= export_search.solr_documents
  end

  # NOTE: do not memoize
  # @return [AMS::Export::Search::CombinedIDSearch] instance used for performing
  #   search and returning solr document results.
  def export_search
    AMS::Export::Search::CombinedIDSearch.new(ids: asset_ids_queue, user: user)
  end

  def validate_user
    errors.add(:user, "is required") unless user.is_a? User
  end

  def valudate_assets_exist
    not_found = asset_ids_queue - found_docs.map(&:id)
    errors.add(:asset_ids_queue, "The following IDs are not found in the repository: #{not_found.join(', ')}") if not_found.present?
  end

  def validate_assets_have_titles
    # Check for missing titles. And yes, SolrDocument#title returns an array
    # of a single element, hence the call to `doc.title.first`.
    # Add an error message any IDs missing titles.
    missing_titles = found_docs.select { |doc| doc.title.first.empty? }.map(&:id)
    errors.add(:asset_ids_queue, "The following IDs are missing a title: #{missing_titles.join(', ')}") if missing_titles.present?
  end

  def validate_assets_have_descriptions
    # Check for missing titles. Unlike title, display_description is a string or nil, so need to call .to_s before checking .empty?
    missing_descriptions = found_docs.select { |doc| doc.display_description.to_s.empty? }.map(&:id)
    errors.add(:asset_ids_queue, "The following IDs are missing a description: #{missing_descriptions.join(', ')}") if missing_descriptions.present?
  end

  def validate_assets_chilren_validation_status
    if assets_with_invalid_children_status.present?
      assets_witth_invalid_children_status.each do |status, asset_ids|
        errors.add(:asset_ids_queue, "The following Assets have invalid status '#{status}': #{asset_ids.join(', ')}")
      end
    end
  end

  def validate_lua_and_sonyci_id
    with_lua_no_sony_ci_id = found_docs.select do |doc|
      doc.level_of_user_access.first.present? && doc.sonyci_id.empty?
    end.map(&:id)

    with_sonyci_id_no_lua = found_docs.select do |doc|
      doc.sonyci_id.present? && doc.level_of_user_access.first.to_s.empty?
    end

    errors.add(:asset_ids_queue, "The following IDs have a Level of User Access but no Sony CI ID: #{with_lua_no_sony_ci_id.join(', ')}") if with_lua_no_sony_ci_id.present?
    errors.add(:asset_ids_queue, "The following IDs have a Sony CI ID but no Level of User Access: #{with_sonyci_id_no_lua.join(', ')}") if with_sonyci_id_no_lua.present?
  end

  def assets_with_invalid_children_status
    {}.tap do |hash|
      found_docs.reject do |doc|
        doc.validation_status_for_aapb == [AssetResource::VALIDATION_STATUSES[:valid]]
      end.each do |doc|
        status = doc.validation_status_for_aapb.first
        hash[status] ||= []
        hash[status] << doc.id
      end
    end
  end
end
