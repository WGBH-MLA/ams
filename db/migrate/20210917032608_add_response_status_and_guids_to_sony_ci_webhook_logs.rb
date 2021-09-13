class AddResponseStatusAndGuidsToSonyCiWebhookLogs < ActiveRecord::Migration[5.1]
  def change
    change_table(:sony_ci_webhook_logs) do |t|
      t.string :guids
      t.integer :response_status

      t.index :guids
    end
  end
end
