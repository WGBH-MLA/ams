class PublishPbcoreJsonJob < ApplicationJob

  # TODO: should we still use this queue, preiously exclusvely used for PushToAAPBJob?
  queue_as :push_to_aapb

  after_enqueue do |job|
    published_asset.update!(
      status: 'queued',
      job_id: job.provider_job_id
    )
  end


  before_perform do |job|
    published_asset.update!(
      status: 'uploading',
      job_id: job.provider_job_id
    )
  end

  after_perform do
    published_asset.update!(
      status: 'finished',
      location: object.public_url
    )
    published_asset.remove_from_parent_asset_id_queue!
  end

  def handle_error(error)
    published_asset.update_with_error!(error)
    super(error)
  end

  # 
  def perform(pbcore_json_hash:, user:, published_asset:)
    upload_to_s3
  end

  private

    # Convenience accessors for named arguments.
    def pbcore_json_hash; @pbcore_json_hash ||= named_arguments[:pbcore_json_hash]; end
    def user; @user ||= named_arguments[:user]; end
    def published_asset; @published_asset ||= named_arguments[:published_asset]; end

    # Uploads the PBCore JSON file to S3 with appropriate content disposition and type for downloading.
    def upload_to_s3
      object.upload_file(pbcore_json_file, content_disposition: 'attachment', content_type: 'application/json')
    end

    # Initializes the S3 client with credentials from environment variables and returns an S3 resource object.
    def s3
      @s3 ||= begin
        Aws.config.update(
          region: 'us-east-1',
          credentials: Aws::Credentials.new(ENV.fetch("AWS_ACCESS_KEY_ID"), ENV.fetch("AWS_SECRET_ACCESS_KEY"))
        )
        Aws::S3::Resource.new(region: 'us-east-1')
      end
    end

    # Creates a temporary file containing the PBCore JSON data, which is then
    # uploaded to S3. The file is rewound after writing to ensure it can be read
    # from the beginning during upload.
    def pbcore_json_file
      file = Tempfile.new(filename)
      file.write(pbcore_json_hash.to_json)
      file.rewind
      file
    end

    # Generates a filename for the PBCore JSON file based on the asset ID,
    # removing the "cpb-aacip-" prefix and appending ".json".
    def filename
      "#{asset_id.sub("cpb-aacip-", '')}.json"
    end

    # Extracts the asset ID from the PBCore JSON hash by looking for the
    # identifier with the source "http://americanarchiveinventory.org".
    def asset_id
      pbcore_identifier = pbcore_json_hash['pbcoreDescriptionDocument']['pbcoreIdentifier'].detect do |id|
        id['source'] == 'http://americanarchiveinventory.org'
      end
      pbcore_identifier['text']
    end

    # Returns the S3 bucket object for the specified bucket name, memoizing it
    # for future use.
    def bucket
      @bucket ||= s3.bucket(bucket_name)
    end

    # Returns the S3 object for the specified filename within the bucket.
    def object
      bucket.object(filename)
    end


    # Returns the name of the S3 bucket to which the PBCore JSON file will be
    # uploaded.
    def bucket_name
      # TODO: Env var only, no default. If not specified, need to error.
      ENV.fetch('S3_PUBLISH_ASSET_BUCKET', 'pbcore-json-aapb-dev')
    end
end
