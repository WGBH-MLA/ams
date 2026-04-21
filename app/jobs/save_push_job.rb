class SavePushJob < ApplicationJob
  queue_as :push_to_aapb

  def perform(push:, pushed_id_csv:, user:)
    push.pushed_id_csv = pushed_id_csv
    # TODO: Changed "pushed" to be a more reflective status to indiatte the records are still processing.
    push.status = 'pushed'
    push.save!


    push.push_ids.each do |asset_id|
      pbcore_json_hash = SolrDocument.find(asset_id).export_as_pbcore_json
      PublishPbcoreJsonJob.perform_later(pbcore_json_hash: pbcore_json_hash, user: user)
    end
  end
end