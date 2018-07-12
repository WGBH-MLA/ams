class AdminData < ApplicationRecord
  self.table_name = "admin_data"
  include ::EmptyDetection

  serialize :special_collection, Array
  serialize :sonyci_id, Array

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
    raise ActiveRecord::RecordNotFound, "Couldn't find AdminData matching GID '#{gid}'" unless result
    result
  end

  # Return the Global Identifier for this admin data.
  # @return [String] Global Identifier (gid) for this AdminData (e.g.gid://ams/admindata/1)
  def gid
    URI::GID.build(app: GlobalID.app, model_name: model_name.name.parameterize.to_sym, model_id: id).to_s if id
  end

end
