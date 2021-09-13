class SonyCi::WebhookLogsController < ApplicationController

  before_action(only: :index) do
    @pagination = Pagination.new(
                    total: SonyCi::WebhookLog.count,
                    page: params.fetch('page', 1),
                    per_page: params.fetch('per_page', 50)
                  )
  end

  # GET /sony_ci/webhook_logs
  # GET /sony_ci/webhook_logs.json
  def index
    @presenters = sony_ci_webhook_logs.map do |sony_ci_webhook_log|
      SonyCi::WebhookLogPresenter.new(sony_ci_webhook_log)
    end
  end

  # GET /sony_ci/webhook_logs/1
  # GET /sony_ci/webhook_logs/1.json
  def show
    respond_to do |format|
      format.html do
        @presenter = SonyCi::WebhookLogPresenter.new(sony_ci_webhook_log)
      end
      format.json
    end
  end

  private
    def sony_ci_webhook_log
      @sony_ci_webhook_log ||= SonyCi::WebhookLog.find(params[:id])
    end

    def sony_ci_webhook_logs
      @sony_ci_webhook_logs ||= SonyCi::WebhookLog.all.order(sort_order).limit(per_page).offset(offset)
    end

    def sort_order
      { created_at: :desc }
    end

    def per_page
      params.fetch(:per_page, 50).to_i
    end

    def offset
      [0, page.to_i - 1].max * per_page
    end

    def page
      params.fetch(:page, 1)
    end

    class Pagination
      attr_reader :total, :page, :per_page
      def initialize(total:, page: 1, per_page: 50)
        @total, @page, @per_page = total.to_i, page.to_i, per_page.to_i
      end

      def showing
        "#{lower_bound} - #{upper_bound}"
      end

      private

        def lower_bound
          ((page - 1) * per_page) + 1
        end

        def upper_bound
          [ ( page * per_page ), total ].min
        end
    end
end
