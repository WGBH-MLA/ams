module SonyCi
  class WebhookLogPresenter

    DATETIME_FORMAT = '%m/%d/%Y %I:%M:%S %P'

    attr_reader :webhook_log

    delegate :id, :url, :error, :error_message, :status, :guids,
             to: :webhook_log

    def initialize(webhook_log)
      raise ArgumentError, "expected first parameter to be a " \
                           "SonyCi::WebhookLog but #{webhook_log.class} was " \
                           "given" unless webhook_log.is_a? SonyCi::WebhookLog
      @webhook_log = webhook_log
    end

    def status
      webhook_log.error ? "Fail" : "Success"
    end

    def created_at
      webhook_log.created_at.strftime(DATETIME_FORMAT)
    end

    def action
      WebhookLogPresenter.actions[webhook_log.action] || "None"
    end

    def request_headers
      return "None" unless webhook_log.request_headers
      http_headers(webhook_log.request_headers)
    end

    def request_body
      return "None" unless webhook_log.request_body
      JSON.pretty_generate(webhook_log.request_body)
    end

    def response_headers
      return "None" unless webhook_log.response_headers
      http_headers(webhook_log.response_headers)
    end

    def response_body
      return "None" unless webhook_log.response_body
      JSON.pretty_generate(webhook_log.response_body)
    end

    private

      def http_headers(headers_hash)
        headers_hash.map { |header, val|
          "#{header}: #{val}"
        }.join("\n")
      end


    class << self
      # Returns a mapping of recognized actions from SonyCi::WebhookController
      # to display text.
      def actions
        {
          'save_sony_ci_id' => "Link Asset to Sony Ci Media"
        }
      end
    end
  end
end
