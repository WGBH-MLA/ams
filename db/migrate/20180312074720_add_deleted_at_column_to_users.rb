class AddDeletedAtColumnToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :deleted_at, :datetime
    add_column :users, :deleted, :boolean, default: false
  end
end