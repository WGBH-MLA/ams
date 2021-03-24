module AMS
  module Export
    module Delivery
      class S3Delivery < Base

        def deliver
          object.upload_file(export_results.filepath, acl: 'public-read', content_disposition: 'attachment', content_type: export_results.content_type)
          notification_data[:download_url] = object.public_url
        end

        private

          def client
            @s3 ||= begin
              Aws.config.update(
                region: 'us-east-1',
                credentials: Aws::Credentials.new(ENV['AWS_ACCESS_KEY'], ENV['AWS_SECRET_KEY'])
              )
              Aws::S3::Resource.new(region: 'us-east-1')
            end
          end

          def bucket
            @bucket ||= client.bucket(bucket_name)
          end

          def object
            @object ||= bucket.object(object_key)
          end

          def object_key
            [ export_dir, File.basename(export_results.filepath) ].compact.join('/')
          end

          def bucket_name
            ENV.fetch('S3_EXPORT_BUCKET', 'ams_exports')
          end

          def export_dir
            ENV.fetch('S3_EXPORT_DIR', nil)
          end
      end
    end
  end
end
