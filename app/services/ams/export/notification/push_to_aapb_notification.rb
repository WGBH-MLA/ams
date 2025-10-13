module AMS
  module Export
    module Notification
      class PushToAAPBNotification < Base
        def send_failure(error_message: nil)
          mail_params[:error_message] = error_message
          mailer.push_to_aapb_failed.deliver_later
        end

        def send_success
          mailer.push_to_aapb_succeeded.deliver_later
        end
      end
    end
  end
end
