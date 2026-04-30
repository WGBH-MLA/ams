class PublishedAsset < ApplicationRecord
  belongs_to :push

  # Available values for `status` field.
  # Happy path for a PublishedAsset is:
  # initiated => queued => uploading => finished
  # NOTE: A PublishedAsset record can have a status of 'finished' with also a value for 'error'.
  enum status: {
    initiated: "initiated",
    queued: "queued",
    uploading: "uploading",
    finished: "finished"
  }

  # Removes the Asset ID from the parent push's asset_ids_queue and updates the
  # push's status to 'finished' if the queue is empty.
  def remove_from_parent_asset_id_queue!
    # Wrap in a transaction because there a race condition can corrupt the
    # asset_ids_queue.
    ActiveRecord::Base.transaction do
      updated_asset_ids_queue = push.reload.asset_ids_queue - [asset_id]
      push.update!(
        asset_ids_queue: updated_asset_ids_queue,
        # Set to 'finished' if the asset_ids_queue field is now empty; otherwise
        # keep current status.
        status: updated_asset_ids_queue.empty? ? 'finished' : push.status
      )
    end
  end

  def update_with_error!(error)
    update!(
      status: 'finished',
      location: nil,
      error: "#{error.class}: #{error.message}"
    )
  end
end
