class AddPushesTable < ActiveRecord::Migration[5.1]
  def change
    create_table :pushes do |t|
      t.string :pushed_id_csv
      t.timestamps null: false
    end
  end
end
