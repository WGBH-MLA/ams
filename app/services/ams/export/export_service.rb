require_relative '../../../../lib/ams/aapb'

module AMS
  module Export
    class ExportService
      attr_reader :solr_documents
      attr_reader :format
      attr_reader :filename
      attr_reader :file_path
      attr_reader :s3_path
      attr_reader :export_type

      attr_accessor :export_data

      # user is needed to 
      def initialize(solr_documents, filename: nil, user: nil, export_type: nil)
        
        # this is used for emailing push-to-aapb summaries in a PushedZip export_records_job
        @user = user

        @solr_documents = solr_documents
        @format = format
        @filename = if filename.nil?
                      "export-#{Time.now.strftime('%m_%d_%Y_%H:%M')}.#{format}"
                    else
                      filename
                    end
        @file_path = Tempfile.new([@filename, ".#{@format}"])
        @s3_path = nil
        @export_type = export_type
        raise 'export_type was not defined!' unless @export_type

        # call this my damn self
        process
      end

      def format
        raise 'Whoa there! Format is required! Did you define a #format method in your export adaptor class?'
      end

      def process
        begin
          # this actually creates the export data, using a #process_export method defined in each subclass of ExportService
          @export_data = process_export
          # determine which after-package action to take

          # if format == 'zip'
          if @export_type == 'pushed_zip_job'
            # DocumentsToPushedZip 

            # uses @file_path var (defined in ExportService#initialize) to send zip from tmp location to aapb
              scp_to_aapb
          elsif @export_type == 'csv_download'

            # DocumentsToCsv, UI download
            export_file = File.read(@export_data.file_path)
            send_data export_file, :type => 'text/csv; charset=utf-8; header=present', :disposition => "attachment; filename=#{@export_data.filename}", :filename => "#{@export_data.filename}"
          elsif @export_type == 'pbcore_download'

            # DocumentsToPbcoreXml, UI download
            export_file = File.read(@export_data.file_path)
            send_data export_file, :type => 'application/zip', :filename => "#{@export_data.filename}"
          elsif ['csv_job', 'pbcore_job'].include?(@export_type)
            # DocumentsToPbcoreXml or DocumentsToCsv

            # upload zip to s3 for download
            upload_to_s3
            Ams2Mailer.export_notification(@user, @export_data.s3_path).deliver_later
          end
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
          if format == 'csv'
            obj.upload_file(f, acl: 'public-read', content_disposition: 'attachment', content_type: 'text/csv')
          else
            obj.upload_file(f, acl: 'public-read', content_disposition: 'attachment')
          end
        end
        @s3_path = obj.public_url
      end

      def aapb_key_path
        if Rails.env.production?
          '-i /home/ec2-user/.ssh/id_rsa'
        end
      end

      def scp_to_aapb
        filepath = @file_path.path

        if aapb_key_path && AMS::AAPB.reachable? && filepath.present?
          aapb_host = AMS::AAPB.host
          output = []

          output << `scp #{aapb_key_path} #{filepath} ec2-user@#{aapb_host}:/home/ec2-user/ingest_zips/#{@filename}`
          output << `ssh #{aapb_key_path} ec2-user@#{aapb_host} '/bin/bash unzip -d /home/ec2-user/ingest_zips -ov /home/ec2-user/ingest_zips/#{@filename}'`
          output << `ssh #{aapb_key_path} ec2-user@#{aapb_host} '/bin/bash cd /var/www/aapb/current && RAILS_ENV=production /home/ec2-user/.gem/ruby/gems/bundler-1.16.5/exe/bundle exec /usr/bin/ruby scripts/download_clean_ingest.rb --files /home/ec2-user/ingest_zips/*.xml'`

          # output << `ssh #{aapb_key_path} ec2-user@#{aapb_host} '/bin/bash cd /var/www/aapb/current && /home/ec2-user/bundle show rest-client'`
# /home/ec2-user/.gem/ruby/gems/bundler-1.16.5/exe/bundle

          # print and email
          Rails.logger.info output
          Ams2Mailer.scp_to_aapb_notification(@user, output.join("\n\n")).deliver_later
        else
          raise "AAPB was unreachable! #{ENV['AAPB_HOST']}"
        end
      end
    end
  end
end
