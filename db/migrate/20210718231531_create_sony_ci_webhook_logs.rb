class CreateSonyCiWebhookLogs < ActiveRecord::Migration[5.1]
  def change
    create_table :sony_ci_webhook_logs do |t|
      t.string :url
      t.string :action
      t.text :request_headers
      t.text :request_body
      t.text :response_headers
      t.text :response_body
      t.string :error
      t.string :error_message
      t.timestamps
    end
  end
end
