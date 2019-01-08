class CreateInstantiationAdminData < ActiveRecord::Migration[5.1]
  def change
    create_table :instantiation_admin_data do |t|
      t.string :aapb_preservation_lto
      t.string :aapb_preservation_disk

      t.timestamps
    end
  end
end
