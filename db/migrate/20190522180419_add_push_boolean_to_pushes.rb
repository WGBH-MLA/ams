class AddPushBooleanToPushes < ActiveRecord::Migration[5.1]
  def change
    add_column :admin_data, :needs_update, :boolean
  end
end
