class AddBulkraxImporterToAdminData < ActiveRecord::Migration[5.1]
  def change
    unless column_exists? :admin_data, :bulkrax_importer_id
      add_reference :admin_data, :bulkrax_importer, foreign_key: true
    end
  end
end
