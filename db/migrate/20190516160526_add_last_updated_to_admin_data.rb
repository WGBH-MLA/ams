class AddLastUpdatedToAdminData < ActiveRecord::Migration[5.1]
  def change
    add_column :admin_data, :last_updated, :string
  end
end
