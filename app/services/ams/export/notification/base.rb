module AMS
  module Export
    module Notification
      class Base
        include ActiveModel::Validations

        attr_reader :user, :delivery

        def initialize(user:, delivery:)
          @user = user
          @delivery = delivery
        end

        def send_failure(error_message: nil)
          raise "Implement #{self.class}#failure to send notifications of failed export."
        end

        def send_success
          raise "Implement #{self.class}#success to send notifications of successful export."
        end

        private

          def mailer
            @mailer ||= ExportMailer.with(mail_params)
          end

          # Returns a hash of params passed to the mailer. By default, this
          # includes the user and any mail data from the Delivery instance.
          # Subclasses may add additional data to the mail_params
          def mail_params
            @mail_params ||= delivery.notification_data.merge(user: user)
          end
      end
    end
  end
end
