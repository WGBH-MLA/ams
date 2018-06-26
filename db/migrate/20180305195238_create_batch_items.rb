class CreateBatchItems < ActiveRecord::Migration[5.1]
  def change
    create_table :batch_items do |t|
      t.integer :batch_id
      t.integer :row_number
      t.string :accession_number
      t.text :attribute_hash
      t.string :status
      t.text :error
      t.string :created_item

      t.timestamps
    end
  end
end
