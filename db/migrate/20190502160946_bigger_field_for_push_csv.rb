class BiggerFieldForPushCsv < ActiveRecord::Migration[5.1]
  def change
    change_column :pushes, :pushed_id_csv, :text
  end
end
