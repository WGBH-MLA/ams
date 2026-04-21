class PublishPbcoreJsonJob < ApplicationJob

  # TODO: should we still use this queue, preiously exclusvely used for PushToAAPBJob?
  queue_as :push_to_aapb

  rescue_from do |error|
    Rails.logger.error "#{error.class}: #{error.message}\n\nBacktrace:\n#{error.backtrace.join("\n")}"
    notification.send_failure(error_message: error.message)
  rescue => secondary_error
    # Double rescue!! Sometimes the rescue_from block throws an error.
    # NOTE: Unrescued errors will be retried by Sidekiq, which we don't want to
    # do if there is no chance of success.
    Rails.logger.error "#{secondary_error.class}: #{secondary_error.message}\n\nBacktrace:\n#{secondary_error.backtrace.join("\n")}"
  end

  # Kicks off jobs for each
  def perform(pbcore_json_hash:, user:)
    upload_to_s3
  end

  private

    def pbcore_json_hash; @pbcore_json_hash ||= named_arguments[:pbcore_json_hash]; end
    def user; @user ||= named_arguments[:user]; end

    def upload_to_s3
      Rails.logger.info "Uploading PBCore JSON...\nAsset ID: #{asset_id}\nUser: #{user.email}\nFilename: #{filename}\nBucket: #{bucket_name}"
      object.upload_file(pbcore_json_file, content_disposition: 'attachment', content_type: 'application/json')
    end

    def s3
      @s3 ||= begin
        Aws.config.update(
          region: 'us-east-1',
          # credentials: Aws::Credentials.new(ENV['AWS_ACCESS_KEY'], ENV['AWS_SECRET_KEY'])
          # DO NOT COMMIT CREDENTIALS!!!
          credentials: Aws::Credentials.new(ENV.fetch("AWS_ACCESS_KEY_ID"), ENV.fetch("AWS_SECRET_ACCESS_KEY"))
        )
        Aws::S3::Resource.new(region: 'us-east-1')
      end
    end

    def pbcore_json_file
      file = Tempfile.new(filename)
      file.write(pbcore_json_hash.to_json)
      file.rewind
      file
    end

    def filename
      "#{asset_id.sub("cpb-aacip-", '')}.json"
    end

    def asset_id
      pbcore_identifier = pbcore_json_hash['pbcoreDescriptionDocument']['pbcoreIdentifier'].detect do |id|
        id['source'] == 'http://americanarchiveinventory.org'
      end
      pbcore_identifier['text']
    end

    def bucket
      @bucket ||= s3.bucket(bucket_name)
    end

    def object
      @object ||= bucket.object(filename)
    end

    def bucket_name
      # TODO: Env var only, no default. If not specified, need to error.
      ENV.fetch('S3_PUBLISH_ASSET_BUCKET', 'pbcore-json-aapb-dev')
    end
end
