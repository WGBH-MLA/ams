class AddLastPushedToAdminData < ActiveRecord::Migration[5.1]
  def change
    add_column :admin_data, :last_pushed, :string
  end
end
