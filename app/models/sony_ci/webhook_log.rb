class SonyCi::WebhookLog < ApplicationRecord
  serialize :request_header, JSON
  serialize :request_body, JSON
  serialize :response_header, JSON
  serialize :response_body, JSON
end
