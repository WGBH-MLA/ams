class ChangePushDateFieldsToInteger < ActiveRecord::Migration[5.1]
  def change
    change_column :admin_data, :last_pushed, :integer
    change_column :admin_data, :last_updated, :integer
  end
end
