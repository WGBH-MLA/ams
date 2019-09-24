class AddMd5ToInstantiationAdminData < ActiveRecord::Migration[5.1]
  def change
    add_column :instantiation_admin_data, :md5, :string
  end
end
