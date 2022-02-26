require 'rails_helper'

RSpec.describe "sony_ci/webhook_logs/index", type: :view do
  let(:webhook_logs) { create_list(:sony_ci_webhook_log, rand(3..7)) }
  let(:presenters) {
    webhook_logs.map { |webhook_log|
      SonyCi::WebhookLogPresenter.new(webhook_log)
    }
  }

  before(:each) do
    assign(:presenters, presenters)
    render
  end

  it "renders a list of sony_ci/webhook_logs" do
    presenters.each do |presenter|
      expect(rendered).to include presenter.created_at
      expect(rendered).to include presenter.action
      expect(rendered).to include presenter.status
      presenter.guids.each do |guid|
        expect(rendered).to include guid
      end
    end
  end
end
