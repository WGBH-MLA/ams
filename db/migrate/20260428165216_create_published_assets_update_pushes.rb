class CreatePublishedAssetsUpdatePushes < ActiveRecord::Migration[6.1]
  def up
    # Before changing schema, migrate pushes.status to new enumerable values:
    # 'pending' => 'initiated'
    # 'pushed' => 'finished'
    execute <<~SQL
      UPDATE pushes
      SET status = 'initiated'
      WHERE status = 'pending';
    SQL

    execute <<~SQL
      UPDATE pushes
      SET status = 'finished'
      WHERE status = 'pushed';
    SQL

    # Create the new published_assets table to track the status of each
    # individual asset being published as part of a push.
    create_table :published_assets do |t|
      t.string :job_id
      t.string :asset_id
      t.references :push, null: false, foreign_key: true
      t.integer :status
      t.string :location
      t.text :error

      t.timestamps
    end

    # Add indexes to the published_assets table for faster queries.
    add_index :published_assets, [:asset_id, :status]
    add_index :published_assets, [:push_id, :status]
    add_index :published_assets, :created_at
    add_index :published_assets, :updated_at


    # Update the pushes table to include new columns for tracking the destination, queue of asset IDs, and any errors.
    add_column(:pushes, :destination, :string)
    add_column(:pushes, :asset_ids_queue, :text)
    add_column(:pushes, :error, :text)
  end

  # The down method should reverse the changes made in the up method, including dropping the published_assets table and removing the added columns from the pushes table. It should also revert the status changes made to the pushes records.
  # (Hopefully we don't have to use this, but it's here for data safety! :)
  def down
    drop_table :published_assets

    remove_column(:pushes, :destination)
    remove_column(:pushes, :asset_ids_queue)
    remove_column(:pushes, :error)

    execute <<~SQL
      UPDATE pushes
      SET status = 'pending'
      WHERE status = 'initiated';
    SQL

    execute <<~SQL
      UPDATE pushes
      SET status = 'pushed'
      WHERE status = 'finished';
    SQL
  end
end
