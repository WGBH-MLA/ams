class AddUserIdToPush < ActiveRecord::Migration[5.1]
  def change
    add_column :pushes, :user_id, :integer
  end
end
