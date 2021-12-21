class AddBulkraxImporterToAdminData < ActiveRecord::Migration[5.1]
  def change
    add_reference :admin_data, :bulkrax_importer, foreign_key: true
  end
end
