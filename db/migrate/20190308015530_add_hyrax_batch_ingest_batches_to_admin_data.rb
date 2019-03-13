class AddHyraxBatchIngestBatchesToAdminData < ActiveRecord::Migration[5.1]
  def change
    add_reference :admin_data, :hyrax_batch_ingest_batch, foreign_key: true
  end
end
