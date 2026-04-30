class SavePushJob < ApplicationJob
  queue_as :push_to_aapb

  # Before we start enqueuing PublishPbcoreJsonJob jobs in #perform, set status to 'queueing'.
  before_perform { push.update!(status: 'queueing') }

  # After perform, when all PublishPbcoreJsonJob have been enqueued
  after_perform { push.update!(status: 'uploading') }


  def handle_error(error)
    push.update!(
      status: 'finished',
      error: "#{error.class}: #{error.message}"
    )
    super(error)
  end

  # For each Asset ID in the Push record, create a PublishedAsset record for
  # tracking and enqueue a PublishPbcoreJsonJob to upload the PBCore JSON to S3.
  def perform(push:)
    push.asset_ids_queue.each do |asset_id|

      # Create a PublishedAsset record, belonging to parent Push record, for
      # tracking the PublishPbcoreJsonJob.
      published_asset = PublishedAsset.create!(
        asset_id: asset_id,
        push: push,
        status: 'initiated'
      )
      
      # Get the PBCore JSON for publishing.
      pbcore_json_hash = SolrDocument.find(asset_id).export_as_pbcore_json
      
      # Queue PublishPbcoreJsonJob job
      PublishPbcoreJsonJob.perform_later(
        pbcore_json_hash: pbcore_json_hash,
        user: user,
        published_asset: published_asset
      )
    end
  end

  private

    # Convenience accessor for named argument `push`.
    def push; @push ||= named_arguments[:push]; end
end