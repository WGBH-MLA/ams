class Push < ActiveRecord::Migration[6.1]
  def change
    add_column :pushes, :status, :string, default: nil
  end
end
