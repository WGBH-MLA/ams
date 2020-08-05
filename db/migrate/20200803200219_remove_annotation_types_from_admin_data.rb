class RemoveAnnotationTypesFromAdminData < ActiveRecord::Migration[5.1]
  def change
    remove_column :admin_data, :level_of_user_access, :string
    remove_column :admin_data, :minimally_cataloged, :string
    remove_column :admin_data, :outside_url, :string
    remove_column :admin_data, :special_collection, :text
    remove_column :admin_data, :transcript_status, :string
    remove_column :admin_data, :licensing_info, :text
    remove_column :admin_data, :playlist_group, :string
    remove_column :admin_data, :playlist_order, :integer
    remove_column :admin_data, :organization, :string
    remove_column :admin_data, :special_collection_category, :string
    remove_column :admin_data, :canonical_meta_tag, :string
  end
end
