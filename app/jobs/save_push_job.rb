class SavePushJob < ApplicationJob
  queue_as :push_to_aapb

  def perform(push:, pushed_id_csv:)
    begin
      push.pushed_id_csv = pushed_id_csv
      push.status = 'pushed'
      push.save!
    rescue => e
      Rails.logger.error("SavePushJob failed for push ID #{push.id}: #{e.message}")
      push.update(status: "Push Error: #{e.message}")
    end
  end
end
