module AMS
  module Export
    module Notification
      class ExportToS3Notification < Base
        def send_failure(error_message: nil)
          mail_params[:error_message] = error_message
          mailer.export_to_s3_failed.deliver_now
        end

        def send_success
          mailer.export_to_s3_succeeded.deliver_now
        end
      end
    end
  end
end
