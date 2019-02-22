class AddBatchIdToAdminData < ActiveRecord::Migration[5.1]
  def change
    add_column :admin_data, :batch_id, :integer
  end
end
