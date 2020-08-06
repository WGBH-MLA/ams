class AdminData < ApplicationRecord
  attr_reader :asset_error

  belongs_to  :hyrax_batch_ingest_batch, optional: true
  has_many    :annotations

  self.table_name = "admin_data"
  include ::EmptyDetection

  # CAN BE REMOVED AFTER MIGRATION TO ANNOTATIONS
  serialize :special_collection, Array
  # CAN BE REMOVED AFTER MIGRATION TO ANNOTATIONS
  serialize :special_collection_category, Array

  serialize :sonyci_id, Array

  SERIALIZED_FIELDS = [ :sonyci_id ]

  # CAN BE REMOVED AFTER MIGRATION
  DEPRECATED_ADMIN_DATA_FIELDS = [ :level_of_user_access, :minimally_cataloged, :outside_url, :special_collection, :transcript_status, :licensing_info, :playlist_group, :playlist_order, :organization, :special_collection_category, :canonical_meta_tag ]

  # Find the admin data associated with the Global Identifier (gid)
  # @param [String] gid - Global Identifier for this admin_data (e.g.gid://ams/admindata/1)
  # @return [AdminData] if record matching gid is found, an instance of AdminData with id = the model_id portion of the gid (e.g. 1)
  # @return [False] if record matching gid is not found
  def self.find_by_gid(gid)
    find(GlobalID.new(gid).model_id)
  rescue ActiveRecord::RecordNotFound, URI::InvalidURIError
    false
  end

  # Find the admin data associated with the Global Identifier (gid)
  # @param [String] gid - Global Identifier for this adimindata (e.g. gid://ams/admindata/1)
  # @return [AdminData] an instance of AdminData with id = the model_id portion of the gid (e.g. 1)
  # @raise [ActiveRecord::RecordNotFound] if record matching gid is not found
  def self.find_by_gid!(gid)
    result = find_by_gid(gid)
    raise ActiveRecord::RecordNotFound, "Couldn't find AdminData matching GID #{gid}" unless result
    result
  end

  # Return the Global Identifier for this admin data.
  # @return [String] Global Identifier (gid) for this AdminData (e.g.gid://ams/admindata/1)
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
end
