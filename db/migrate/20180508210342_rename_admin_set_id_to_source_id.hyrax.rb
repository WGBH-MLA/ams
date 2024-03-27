class RenameAdminSetIdToSourceId < ActiveRecord::Migration[5.1]
  def change
    rename_column :permission_templates, :admin_set_id, :source_id
    Hyrax::PermissionTemplate.reset_column_information
  end
end
