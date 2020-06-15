class CreateAnnotations < ActiveRecord::Migration[5.1]
  def change
    create_table :annotations do |t|
      t.string :annotation_type
      t.string :ref
      t.string :source
      t.string :annotation
      t.string :version
      t.string :value
      t.references :admin_data, foreign_key: true

      t.timestamps
    end
  end
end
