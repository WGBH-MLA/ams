# This migration comes from hyrax_batch_ingest (originally 20181022203038)
# frozen_string_literal: true

class CreateHyraxBatchIngestBatches < ActiveRecord::Migration[5.1]
  def change
    create_table :hyrax_batch_ingest_batches do |t|
      t.string :status
      t.string :submitter_email
      t.string :source_location
      t.text :error
      t.string :admin_set_id
      t.string :ingest_type

      t.timestamps
    end
  end
end
