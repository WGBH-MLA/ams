require 'httparty'

module AMS
  class AAPBRemoteIngester

    attr_reader :host, :filepath, :output, :ssh_key

    def initialize(host:, filepath:, ssh_key:)
      @host = host
      @filepath = filepath
      @ssh_key = ssh_key
      @output = []
    end

    def run!
      run_command_for(:upload, raise_on_failure: UploadFailure)
      run_command_for(:unzip, raise_on_failure: UnzipFailure)
      run_command_for(:ingest, raise_on_failure: IngestFailure)
    end

    def commands
      @commands ||= {
        upload: "scp -i #{ssh_key} #{filepath} ec2-user@#{host}:/home/ec2-user/ingest_zips/#{filename}",
        unzip:  "ssh -i #{ssh_key} ec2-user@#{host} 'unzip -d /home/ec2-user/ingest_zips -o /home/ec2-user/ingest_zips/#{filename}'",
        ingest: "ssh -i #{ssh_key} ec2-user@#{host} 'bash -l -c \"cd /var/www/aapb/current && RAILS_ENV=production bundle exec /usr/bin/ruby scripts/download_clean_ingest.rb --files /home/ec2-user/ingest_zips/*.xml\"'"
      }
    end

    private

      def filename
        File.basename(filepath)
      end

      def run_command_for(command_key, raise_on_failure:)
        # Run the command and capture output, error, and status.
        stdout, stderr, process_status = Open3.capture3(commands.fetch(command_key))

        # If the command failed, raise an error with the error message.
        raise raise_on_failure, stderr unless process_status.exitstatus == 0

        # If the command succeeded, accumulate the output and log it too.
        output << stdout
        Rails.logger.info stdout
      end

    # Some specific error classes to indicate specific problems.
    class UploadFailure < StandardError; end
    class UnzipFailure  < StandardError; end
    class IngestFailure < StandardError; end
  end
end
