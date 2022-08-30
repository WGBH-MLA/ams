class SonyCi::WebhookLog < ApplicationRecord
  serialize :request_headers, JSON
  serialize :request_body, JSON
  serialize :response_headers, JSON
  serialize :response_body, JSON
  serialize :guids, Array

  validates :url, presence: true
  validates :action, presence: true
  validates :response_status, inclusion: { in: 200..599 }
end
