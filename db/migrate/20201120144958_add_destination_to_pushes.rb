class AddDestinationToPushes < ActiveRecord::Migration[5.1]
  def change
    add_column :pushes, :destination, :string, default: "Both"
  end
end
