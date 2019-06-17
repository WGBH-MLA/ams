class ChangeAdmindataFieldsToInt < ActiveRecord::Migration[5.1]
  def up
    change_column :admin_data, :last_updated, :integer
    change_column :admin_data, :last_pushed, :integer
  end
  def down
    change_column :admin_data, :last_updated, :string
    change_column :admin_data, :last_pushed, :string
  end
end
