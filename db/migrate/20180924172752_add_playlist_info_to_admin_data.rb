class AddPlaylistInfoToAdminData < ActiveRecord::Migration[5.1]
  def change
    add_column :admin_data, :playlist_group, :string
    add_column :admin_data, :playlist_order, :integer
  end
end
