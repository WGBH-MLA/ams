module SonyCi
  class WebhooksController < APIController
    after_action :create_webhook_log

    rescue_from StandardError do |error|
      # NOTE: Sony Ci will continue to retry any webhook request that returns
      # a non-2xx status for up to 2 hours, every 5 minutes. Since errors are
      # unlikely to be fixed within this 2 hour window, we avoid the retries
      # and all the noise they would produce by just returning a 200. We
      # log the errors in the webhook_logs table and in the Rails log.
      render json: { error: error.message }, status: 200
    ensure
      create_webhook_log(error: error)
      Rails.logger.error "#{error.class}: #{error.message}"
      Rails.logger.error error.backtrace.join("\n")
    end

    def save_sony_ci_id
      asset_admin_data_from_sony_ci_filename.update!( sonyci_id: [ sony_ci_id ] )
      render status: 200, json: { message: "success" }
    end

    private

      def asset_admin_data_from_sony_ci_filename
        Asset.find(guid_from_sony_ci_filename).admin_data
      end

      def guid_from_sony_ci_filename
        sony_ci_filename.sub(/\..*/, '') unless sony_ci_filename.empty?
      end

      def sony_ci_filename
        params['assets'].first['name']
      end

      def sony_ci_id
        params['assets'].first['id']
      end

      # Creates a WebhookLog record for the webhook request and ensures
      # that it gets saved. Used in an around_action controller callback for
      # webhook actions.
      def create_webhook_log(error: nil)
        webhook_log.response_headers = response.headers.to_h
        webhook_log.response_body = response_json
        if error
          webhook_log.error = error.class
          webhook_log.error_message = error.message
        end
        webhook_log.save!
      end

      def response_json
        return if response.body.empty?
        JSON.parse(response.body)
      end


      def webhook_log
        @webhook_log ||= SonyCi::WebhookLog.new(
          url: request.url,
          action: action_name,
          # There is a bunch of stuff added to the headers by Rails, but we want
          # to save what Sony Ci sends us, which are prefixed with 'HTTP_'.
          request_headers: request.headers.env.slice { |header, val|
            header[0..4] == 'HTTP_'
          },
          # NOTE: the idea here is to store what Sony Ci has sent, so filter
          # out anything that Rails added. (NOTE: we store 'action' in it's
          # own field for sorting)
          request_body: permitted_params.to_h.except(:action, :controller)
        )
      end

      def permitted_params
        params.permit!
      end
  end
end
