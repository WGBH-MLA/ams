module AMS
  module Export
    class ExportService
      attr_reader :solr_documents
      attr_reader :format
      attr_reader :filename
      attr_reader :file_path
      attr_reader :s3_path

      def initialize(solr_documents, format, filename = nil)
        @solr_documents = solr_documents
        @format = format
        @filename = if filename.nil?
                      "export-#{Time.now.strftime('%m_%d_%Y_%H:%M')}.#{format}"
                    else
                      filename
                    end
        @s3_path = nil
      end

      def process
        @file_path = Tempfile.new([@filename, ".#{@format}"])
        begin
          process_export
          yield
        ensure
          @file_path.close
          @file_path.unlink # deletes the temp file.
        end
      end

      def upload_to_s3
        Aws.config.update(
          region: 'us-east-1',
          credentials: Aws::Credentials.new(ENV['AWS_ACCESS_KEY'], ENV['AWS_SECRET_KEY'])
        )
        s3 = Aws::S3::Resource.new(region: 'us-east-1')

        export_file = File.read(@file_path)
        # send file to s3
        obj = s3.bucket(ENV['S3_EXPORT_BUCKET']).object("#{ENV['S3_EXPORT_DIR']}/#{SecureRandom.uuid}/#{@filename}")
        File.open(@file_path, 'r') do |f|
          obj.upload_file(f, acl: 'public-read', content_disposition: 'attachment')
        end
        @s3_path = obj.public_url
      end
    end
  end
end
