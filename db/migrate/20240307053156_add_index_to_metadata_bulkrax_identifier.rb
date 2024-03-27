class AddIndexToMetadataBulkraxIdentifier < ActiveRecord::Migration[6.1]
  def change
    # This creates an expression index on the first element of the bulkrax_identifier array
    add_index :orm_resources, "(metadata -> 'bulkrax_identifier' ->> 0)", name: 'index_on_bulkrax_identifier', where: "metadata -> 'bulkrax_identifier' IS NOT NULL"
  end
end
