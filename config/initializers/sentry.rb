require 'sentry-ruby'

# in Rails, this might be in config/initializers/sentry.rb
Sentry.init do |config|
  config.dsn = ENV['SENTRY_DSN']
  config.environment = ENV['SENTRY_ENVIRONMENT']
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]

  # report exceptions rescued by ActionDispatch::ShowExceptions or ActionDispatch::DebugExceptions middlewares
  # the default value is true
  # config.rails.report_rescued_exceptions = true

  # Set traces_sample_rate to 1.0 to capture 100%
  # of transactions for performance monitoring.
  # We recommend adjusting this value in production.
  config.traces_sample_rate = ENV['SENTRY_TRACES_SAMPLE_RATE'].to_f
  # or
  # config.traces_sampler = lambda do |context|
  #   true
  # end
end unless Rails.env.test?