class ChangePushDateFieldsToInteger < ActiveRecord::Migration[5.1]
  def up
    change_column :admin_data, :last_pushed, :integer, using: 'last_pushed::integer'
    change_column :admin_data, :last_updated, :integer, using: 'last_updated::integer'
  end

  def down
    change_column :admin_data, :last_pushed, :string
    change_column :admin_data, :last_updated, :string
  end
end
