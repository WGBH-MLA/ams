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
        @temp_file = Tempfile.new([@filename, ".#{@format}"])
        @s3_path = nil
        @export_type = export_type
        raise 'export_type was not defined!' unless @export_type

        # call this my damn self
        # this actually creates the export data, using a #process_export method defined in each subclass of ExportService
        @export_data = process_export

        if @export_type.end_with?('_job')
          process_job
        else
          # the only post-work do do for _download jobs is to pass the @temp_file path out to CatalogController
          @tempfile.path
        end
      end

      def format
        raise 'Whoa there! Format is required! Did you define a #format method in your export adaptor class?'
      end

      def process_job
        begin
          # determine which after-package action to take

          # if format == 'zip'
          if @export_type == 'pushed_zip_job'
            # DocumentsToPushedZip 

            # uses @temp_file var (defined in ExportService#initialize) to send zip from tmp location to aapb
            scp_to_aapb
          elsif ['csv_job', 'pbcore_job'].include?(@export_type)
            # DocumentsToPbcoreXml or DocumentsToCsv

            # upload zip to s3 for download
            upload_to_s3
            Ams2Mailer.export_notification(@user, @export_data.s3_path).deliver_later
          end
        ensure
          @temp_file.close
          @temp_file.unlink # deletes the temp file.
        end
      end

      # def process_download
      #   if @export_type == 'csv_download'

      #     # DocumentsToCsv, UI download
      #     # ActionController::DataStreaming.send_data export_file, :type => 'text/csv; charset=utf-8; header=present', :disposition => "attachment; filename=#{@filename}", :filename => "#{@filename}"
      #   elsif @export_type == 'pbcore_download'

      #     # DocumentsToPbcoreXml, UI download
      #     # ActionController::DataStreaming.send_data export_file, :type => 'application/zip', :filename => "#{@export_data.filename}"

      #   end
      # end

      # def process
      #   begin
      #     # determine which after-package action to take

      #     # if format == 'zip'
      #     if @export_type == 'pushed_zip_job'
      #       # DocumentsToPushedZip 

      #       # uses @temp_file var (defined in ExportService#initialize) to send zip from tmp location to aapb
      #         scp_to_aapb
      #     elsif @export_type == 'csv_download'

      #       # DocumentsToCsv, UI download
      #       File.read(@temp_file.path)
      #       # ActionController::DataStreaming.send_data export_file, :type => 'text/csv; charset=utf-8; header=present', :disposition => "attachment; filename=#{@filename}", :filename => "#{@filename}"
      #     elsif @export_type == 'pbcore_download'

      #       # DocumentsToPbcoreXml, UI download
      #       File.read(@temp_file.path)
      #       # ActionController::DataStreaming.send_data export_file, :type => 'application/zip', :filename => "#{@export_data.filename}"
      #     elsif ['csv_job', 'pbcore_job'].include?(@export_type)
      #       # DocumentsToPbcoreXml or DocumentsToCsv

      #       # upload zip to s3 for download
      #       upload_to_s3
      #       Ams2Mailer.export_notification(@user, @export_data.s3_path).deliver_later
      #     end
      #   ensure
      #     @temp_file.close
      #     @temp_file.unlink # deletes the temp file.
      #   end

      #   data_to_send
      # end

      def upload_to_s3
        Aws.config.update(
          region: 'us-east-1',
          credentials: Aws::Credentials.new(ENV['AWS_ACCESS_KEY'], ENV['AWS_SECRET_KEY'])
        )
        s3 = Aws::S3::Resource.new(region: 'us-east-1')

        export_file = File.read(@temp_file)
        # send file to s3
        obj = s3.bucket(ENV['S3_EXPORT_BUCKET']).object("#{ENV['S3_EXPORT_DIR']}/#{SecureRandom.uuid}/#{@filename}")
        File.open(@temp_file, 'r') do |f|
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
        filepath = @temp_file.path

        if aapb_key_path && AMS::AAPB.reachable? && filepath.present?
          aapb_host = AMS::AAPB.host
          output = []

          output << `scp #{aapb_key_path} #{filepath} ec2-user@#{aapb_host}:/home/ec2-user/ingest_zips/#{@filename}`
          output << `ssh #{aapb_key_path} ec2-user@#{aapb_host} 'unzip -d /home/ec2-user/ingest_zips -o /home/ec2-user/ingest_zips/#{@filename}'`
          output << `ssh #{aapb_key_path} ec2-user@#{aapb_host} 'cd /var/www/aapb/current && RAILS_ENV=production /home/ec2-user/.gem/ruby/gems/bundler-1.16.5/exe/bundle exec /usr/bin/ruby scripts/download_clean_ingest.rb --files /home/ec2-user/ingest_zips/*.xml'`


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
