class AddOrganizationToAapbAdminData < ActiveRecord::Migration[5.1]
  def change
    add_column :admin_data, :organization, :string
  end
end
