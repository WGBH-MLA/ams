# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work_resource AssetResource`
class AssetResource < Hyrax::Work
  include Hyrax::Schema(:basic_metadata)
  include Hyrax::Schema(:asset_resource)

  def admin_data
    @admin_data ||= AdminData.find_by_gid(admin_data_gid)
  end

  def admin_data=(new_admin_data)
    self.admin_data_gid = new_admin_data.gid
  end
end
