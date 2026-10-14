class PublishedAsset < ApplicationRecord
  belongs_to :push

  # Available values for `status` field. Happy path for a PublishedAsset is:
  # initiated => queued => uploading => finished NOTE: A PublishedAsset record
  # can have a status of `finished`` with either a value for `location` or
  # `error`, but probably not both. If we end up with both, that's an edge case
  # we need to handle.
  enum status: {
    initiated: "initiated",
    queued: "queued",
    uploading: "uploading",
    finished: "finished"
  }

  # After ever time a PublishedAsset is create or updated (i.e. saved)...
  after_save do
    # If the status was just changed to "finished"...
    if status == "finished" && saved_change_to_status?
      # Remove the asset_id from the parent Push's asset_ids_queue.
      push.remove_asset_id_from_queue!(asset_id)
    end

    # Update the parent Push's status based on the state of its PublishedAssets.
    push.update_status!
  end

  def finish_with_error!(error:)
    update!(
      status: 'finished',
      location: nil,
      error: "#{error.class}: #{error.message}"
    )
  end

  def finish_with_location!(location:)
    update!(
      status: 'finished',
      location: location,
      error: nil
    )
  end

  # @return True if the status is "finished" AND there are no errors; false
  # otherwise.
  def succeeded?
    error.nil? && status == "finished"
  end

  def result
    reload
    if error.nil? && status == "finished"
      return "succeded"
    elsif error
      return "failed"
    elsif sidekiq_job
      return "running"
    else
      return "unknown"
    end
  end

  def sidekiq_job
    reload
    return unless job_id
    Sidekiq::Queue.new(job_queue_name).find_job(job_id)
  end

  def job_queue_name
    PublishPbcoreJsonJob.queue_name
  end
end
