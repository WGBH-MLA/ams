class AdminData < ApplicationRecord
  self.table_name = "admin_data"
  
  include ::EmptyDetection

  attr_reader :asset_error

  belongs_to  :hyrax_batch_ingest_batch, optional: true
  belongs_to  :bulkrax_importer, optional: true, class_name: 'Bulkrax::Importer'
  has_many    :annotations, dependent: :destroy
  accepts_nested_attributes_for :annotations, allow_destroy: true
  serialize :sonyci_id, Array
  validate :validate_undeletable_fields

  # TODO: Only used in AssetActor, which is deprecated. One AssetActor is
  # removed, remove SERIALIZED_FIELD as well.

  SERIALIZED_FIELDS = [ :sonyci_id ]

  # Mark fields that should not be deletable once set. These are used in validation.
  UNDELETABLE_FIELDS = %w(bulkrax_importer_id hyrax_batch_ingest_batch_id)

  # Find the admin data associated with the Global Identifier (gid)
  # @param [String] gid - Global Identifier for this admin_data (e.g.gid://ams/admindata/1)
  # @return [AdminData] if record matching gid is found, an instance of
  #   AdminData with id = the model_id portion of the gid (e.g. 1)
  # @return [False] if record matching gid is not found
  def self.find_by_gid(gid)
    find(GlobalID.new(gid).model_id)
  rescue ActiveRecord::RecordNotFound, URI::InvalidURIError
    false
  end

  # Find the admin data associated with the Global Identifier (gid)
  # @param [String] gid - Global Identifier for this adimindata\
  #   (e.g. gid://ams/admindata/1)
  # @return [AdminData] an instance of AdminData with id = the model_id portion
  #   of the gid (e.g. 1)
  # @raise [ActiveRecord::RecordNotFound] if record matching gid is not found
  def self.find_by_gid!(gid)
    result = find_by_gid(gid)
    raise ActiveRecord::RecordNotFound, "Couldn't find AdminData matching GID #{gid}" unless result
    result
  end

  # These are the attributes that could be edited through a form or through ingest.
  def self.attributes_for_update
    AdminData.attribute_names.dup - ['id', 'created_at', 'updated_at']
  end

  # Return the Global Identifier for this admin data.
  # @return [String] Global Identifier (gid) for this AdminData
  #   (e.g.gid://ams/admindata/1)
  def gid
    URI::GID.build(app: GlobalID.app, model_name: model_name.name.parameterize.to_sym, model_id: id).to_s if id
  end

  def solr_doc(refresh: false)
    @solr_doc = nil if refresh
    @solr_doc ||= ActiveFedora::Base.search_with_conditions(
      { admin_data_gid_ssim: gid },
      { rows: 99999 }
    ).first
  end

  def asset(refresh: false)
    @asset = @asset_error = nil if refresh
    @asset ||= Asset.find(solr_doc[:id]) unless @asset_error
  rescue => error
    @asset_error = error
    nil
  end

  # Returns a hash of Sony Ci records fetched from the Sony Ci API, keyed
  # by the Sony Ci ID.
  def sonyci_records
    # NOTE: sonyci_id (although singular) is actually a serialized array.
    # We do hit the API per sonyci_id here, but over 99% of the time, there will
    # be only one, and when there's more, there are not a whole bunch.
    @sonyci_records ||= {}.tap do |hash|
      sonyci_id.each { |id| hash[id] = sony_ci_api.asset(id) }
    end
  rescue => e
    Rails.logger.error "Could not retrieve records from Sony Ci API.\n " \
                       "#{e.class}: #{e.message}"
    nil
  end

  def sony_ci_api
    @sony_ci_api ||= SonyCiApi::Client.new('config/ci.yml')
  end

  def validate_undeletable_fields
    UNDELETABLE_FIELDS.each do |field|
      # NOTE: the {field}_was helper comes from ActiveModel::Dirty
      new_val, old_val = send(field), send("#{field}_was")
      if new_val.blank? && old_val.present?
        errors.add(field, "can't change from #{old_val} to blank")
      end
    end
  end
end
