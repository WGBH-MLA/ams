class AddsSpecialCollectionCategoryAndCanonicalMetaTagToAapbAdminData < ActiveRecord::Migration[5.1]
  def change
    add_column :admin_data, :special_collection_category, :string
    add_column :admin_data, :canonical_meta_tag, :string
  end
end
