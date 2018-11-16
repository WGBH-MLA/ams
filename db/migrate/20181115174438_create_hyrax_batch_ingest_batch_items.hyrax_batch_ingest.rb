# This migration comes from hyrax_batch_ingest (originally 20181022204812)
# frozen_string_literal: true

class CreateHyraxBatchIngestBatchItems < ActiveRecord::Migration[5.1]
  def change
    create_table :hyrax_batch_ingest_batch_items do |t|

      t.references :batch, foreign_key: { to_table: :hyrax_batch_ingest_batches }, index: { name: :index_hyrax_batch_ingest_batch_items_on_batch_id }
      t.string :id_within_batch
      t.string :source_data
      t.string :source_location
      t.string :status
      t.text :error
      t.string :object_id

      t.timestamps
    end
  end
end
