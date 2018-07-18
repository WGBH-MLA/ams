class CreateAdminData < ActiveRecord::Migration[5.1]
  def change
    create_table :admin_data do |t|
      t.string :level_of_user_access
      t.string :minimally_cataloged
      t.string :outside_url
      t.text :special_collection
      t.string :transcript_status
      t.text :sonyci_id
      t.text :licensing_info

      t.timestamps
    end
  end
end
