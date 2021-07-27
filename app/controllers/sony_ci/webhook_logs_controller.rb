class SonyCi::WebhookLogsController < ApplicationController
  before_action :set_sony_ci_webhook_log, only: [:show ]

  # GET /sony_ci/webhook_logs
  # GET /sony_ci/webhook_logs.json
  def index
    @sony_ci_webhook_logs = SonyCi::WebhookLog.all
  end

  # GET /sony_ci/webhook_logs/1
  # GET /sony_ci/webhook_logs/1.json
  def show
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sony_ci_webhook_log
      @sony_ci_webhook_log = SonyCi::WebhookLog.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def sony_ci_webhook_log_params
      params.fetch(:sony_ci_webhook_log, {})
    end
end
