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

  after_create do
    asset_ids_queue.each do |asset_id|
      published_assets.create!(
        asset_id: asset_id,
        status: 'initiated'
      )
    end
  end

  # Run custom validations in a single method. This is to allow skipping
  # validation for existing Push records where the status="finished", which
  # should be considered valid without re-running validations, and to allow all
  # validations to run and collect errors before returning a final result.
  validate :run_validations!

  def update_status!
    ActiveRecord::Base.transaction do
      self.reload
      if all_published_assets_present?
        if all_published_assets_finished?
          update!(status: 'finished')
        else
          update!(status: 'uploading')
        end
      else
        update!(status: 'queueing')
      end
    end
  end

  def remove_asset_id_from_queue!(asset_id)
    # Wrap in a transaction because this is called from background jobs that may
    # be running concurrently
    ActiveRecord::Base.transaction do
      updated_asset_ids_queue = reload.asset_ids_queue - [asset_id]
      update!(asset_ids_queue: updated_asset_ids_queue)
      update_status!
    end
  end

  # TODO: use scopes?

  def all_published_assets_present?
    asset_ids_queue.all? do |asset_id|
      published_assets.exists?(asset_id: asset_id)
    end
  end

  def all_published_assets_finished?
    published_assets.all? do |published_asset|
      published_asset.status == "finished"
    end
  end

  def published_assets_failed
    published_assets.select do |published_asset|
      !published_asset.error.nil?
    end
  end

  def published_assets_succeeded
    published_assets.select do |published_asset|
      published_asset.error.nil?
    end
  end


  # For backward compatibility with existing Push records that have
  # asset_ids_queue stored as a comma-separated string instead of an array,
  # split the string on commas and strip whitespace to get an array of IDs. If
  # asset_ids_queue is already an array, this will return the same array.
  def asset_ids_deprecated
    pushed_id_csv.to_s.split(',').map(&:strip) 
  end

  private

  # Memoize the found_docs to avoid performing multiple Solr queries during validation.
  def found_docs
    @found_docs ||= export_search.solr_documents
  end

  # NOTE: do not memoize
  # @return [AMS::Export::Search::CombinedIDSearch] instance used for performing
  #   search and returning solr document results.
  def export_search
    asset_ids = (asset_ids_queue ?  asset_ids_queue : asset_ids_deprecated).to_a
    AMS::Export::Search::CombinedIDSearch.new(ids: asset_ids, user: user)
  end

  def run_validations!
    # If the status is already "finished", skip validations and return true.
    # This allows existing Push records that have already been processed to be
    # considered valid without re-running validations, which could potentially
    # cause errors if the underlying data has changed since the push was
    # processed.
    return true if status == "finished"
      
    # Run all the validation methods. Each validation method will add errors to
    # the model if it finds any issues, but we don't need to check for errors
    # after each validation method because we want to run all validations and
    # collect all errors before returning a final result.
    validate_user
    validate_asset_ids_queue_presesnt
    validate_assets_exist
    validate_assets_have_titles
    validate_assets_have_descriptions
    validate_lua_no_sonyci_id
    validate_sonyci_id_no_lua
    validate_one_lua
    validate_assets_chilren_validation_status

    # Return true if there are no errors, false otherwise.
    errors.empty?
  end

  # Check that the user is present and is an instance of User. If not, adds an
  # error message indicating that a valid user is required.
  def validate_user
    errors.add(:user, "is required") unless user.is_a? User
  end

  def validate_asset_ids_queue_presesnt
    errors.add(
      :asset_ids_queue,
      "One or more Asset IDs is required",
    ) if asset_ids_queue.to_a.empty? && status != "finished"
  end

  # Check that all IDs in asset_ids_queue correspond to existing documents in the
  # repository. If any are not found, adds an error message with the IDs that
  # are not found.
  def validate_assets_exist
    invalid_asset_ids = asset_ids_queue.to_a - found_docs.map(&:id)
    errors.add(
      :asset_ids_queue,
      "Not found in AMS",
      invalid_asset_ids: invalid_asset_ids
    ) if invalid_asset_ids.present?
  end

  # Check for missing titles. SolrDocument#title returns an array of a single
  # element, so call .first to get the title string before checking .empty?. Add
  # an error message any IDs missing titles.
  def validate_assets_have_titles
    # Check for missing titles. See also SolrDocument#title.
    invalid_asset_ids = found_docs.select { |doc| doc.title.empty? }.map(&:id)
    errors.add(
      :asset_ids_queue,
      "No title metadata",
      invalid_asset_ids: invalid_asset_ids
    ) if invalid_asset_ids.present?
  end

  # Check for missing descriptions. SolrDocument#display_description returns a
  # string or nil, so call .to_s before checking .empty?. Add an error message
  # any IDs missing descriptions.
  def validate_assets_have_descriptions
    # Check for missing titles. Unlike title, display_description is a string or nil, so need to call .to_s before checking .empty?
    invalid_asset_ids = found_docs.select { |doc| doc.display_description.to_s.empty? }.map(&:id)
    errors.add(
      :asset_ids_queue,
      "No description metadata",
      invalid_asset_ids: invalid_asset_ids
    ) if invalid_asset_ids.present?
  end

  # Check for any assets with children that have a validation status other than
  # "valid". If any are found, adds an error message for each invalid status and
  # the IDs of the assets with that status.
  def validate_assets_chilren_validation_status
    assets_with_invalid_children_status.each do |status, invalid_asset_ids|
      errors.add(
        :asset_ids_queue,
        status,
        invalid_asset_ids: invalid_asset_ids
      )
    end
  end

  # Checks for any assets that have a Level of User Access but no Sony CI ID, or
  # a Sony CI ID but no Level of User Access. If any are found, adds an error
  # message for each case and the IDs of the assets that violate the rule.
  def validate_lua_no_sonyci_id
    invalid_asset_ids = found_docs.select do |doc|
      doc.level_of_user_access.to_a.present? && doc.sonyci_id.to_a.empty?
    end.map(&:id)

    errors.add(
      :asset_ids_queue,
      "Level of User Access but no Sony Ci ID",
      invalid_asset_ids: invalid_asset_ids
    ) if invalid_asset_ids.present?
  end

  def validate_sonyci_id_no_lua
    invalid_asset_ids = found_docs.select do |doc|
      doc.sonyci_id.present? && doc.level_of_user_access.to_a.empty?
    end

    errors.add(
      :asset_ids_queue,
      "Sony Ci ID but no Level of User Access",
      invalid_asset_ids: invalid_asset_ids
    ) if invalid_asset_ids.present?
  end

  def validate_one_lua
    invalid_asset_ids = found_docs.select do |doc|
      doc.level_of_user_access && doc.level_of_user_access.to_a.size > 1
    end.map(&:id)

    errors.add(
      :asset_ids_queue,
      "More than one Level of User Access",
      invalid_asset_ids: invalid_asset_ids
    ) if invalid_asset_ids.present?
  end

  # Checks for any assets with children that have a validation status other than
  # "valid". If any are found, adds an error message for each invalid status and
  # the IDs of the assets with that status.
  # @return [Hash] of validation status to array of asset ids with that status.
  #   Only includes assets whose validation status is not "valid".
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

  class Summary < SimpleDelegator
    
    def date
      created_at.strftime("%_m/%-d/%Y %l:%M %p")
    end
    
    def status
      # Deprecated records are finished by default
      ( deprecated? ? "finished" : super.to_s ).titleize
    end

    def deprecated?
      pushed_id_csv.to_s.present?
    end

    def asset_count
      if deprecated?
        pushed_id_csv.to_s.split(',').size
      else
        (published_assets.map(&:asset_id) + asset_ids_queue.to_a).uniq.size
      end
    end

    def succeeded
      published_assets.count { |published_asset| published_asset.error.nil? }
    end

    def failed
      published_assets.count(&:error)
    end

    # @return [Hash] a hash of PublishedAsset record counts
    def asset_counts_by_status
      published_assets.group_by(&:status).map do |status, published_assets|
        [ status, published_assets.count ]
      end.to_h
    end

    def asset_counts_by_result
      published_assets.group_by do |published_asset|
        published_asset.error? ? "failed" : "succeeded"
      end.map do |result, published_assets|
        [ result, published_assets.count ]
      end.to_h
    end
  end
end
