FactoryBot.define do
  factory :sony_ci_webhook_log, class: 'SonyCi::WebhookLog' do
    url { Faker::Internet.url }
    action { SonyCi::WebhooksController.action_methods.to_a.sample }
    request_headers { { 'Content-Type' => 'application/json' } }
    request_body {
      {
        "id": "6vzdrfgzff0teglw",
        "type": "AssetProcessingFinished",
        "createdOn": "2017-01-02T00:00:00.000Z",
        "createdBy": {
          "id": "c460dfc1447f4240b14b2f32ce8d4a5f",
          "name": "John Smith",
          "email": "johnsmith@example.com"
        },
        "assets": [
          {
            "id": "kayc4skb5dkk49k7",
            "name": "Movie.mov"
          }
        ]
      }
    }

    # Response headers should always include Content-type of application/json.
    response_headers { { "Content-Type" => "application/json" } }

    # NOTE: the response status does not necesarily mean that no error occurred.
    # Rather, returning a 2xx status tells Sony Ci not to try the request again
    # which is what we want in nearly every use case.
    response_status { 200 }

    # Randomly assing an error.
    error { [true, false].sample ? "FakeError" : nil }

    # Almost always, there is only 1 GUID, but need to allow for multiple.
    guids { [ "cpb-aacip-#{Faker::Number.hexadecimal(11)}" ] }

    after(:build) do |webhook_log|
      if webhook_log.error?
        # Add an error message if we have an error.
        webhook_log.error_message = Faker::Lorem.sentence if webhook_log.error?
        # TODO: This should match what is actually returned by
        # SonyCi::WebhooksController for the given error.
        webhook_log.response_body = { "error" => webhook_log.error_message }
      else
        # TODO: This should match what is actually returned by
        # SonyCi::WebhooksController for the given action.
        webhook_log.response_body = { "success" => true }
      end
    end
  end
end
