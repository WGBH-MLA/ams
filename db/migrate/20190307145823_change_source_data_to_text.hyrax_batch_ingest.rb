# This migration comes from hyrax_batch_ingest (originally 20190124222733)
class ChangeSourceDataToText < ActiveRecord::Migration[5.1]
  def change
    change_column :hyrax_batch_ingest_batch_items, :source_data, :text
  end
end
