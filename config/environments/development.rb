Rails.application.configure do

    # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = !!Sidekiq.server?

  # Verifies that versions and hashed value of the package contents in the project's package.json
  config.webpacker.check_yarn_integrity = false
  # Method for using environment variables for Booleans
  def truthy_env_var?(val)
    ['yes', 'true', '1'].include? val.to_s.downcase.strip
  end

  config.web_console.whitelisted_ips = ['172.18.0.0/16', '172.27.0.0/16', '0.0.0.0/0']

  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  if Rails.root.join('tmp/caching-dev.txt').exist?
    config.action_controller.perform_caching = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.seconds.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # config.assets.prefix = "/assets"
  config.analytics_settings = YAML.load_file(Rails.root.join("config/analytics.yml"))

  # Config background Jobs to use Sidekiq queue, so we can do production-like
  # testing of concurrent background jobs during batch ingests.
  config.active_job.queue_adapter = :sidekiq

  # For testing emails in Development
  # Define as ENV["MAIL_DELIVERY_METHOD"] as 'smtp' to deliver
  # emails in development environment
  config.action_mailer.default_url_options = { host: 'localhost' }
  config.action_mailer.delivery_method = ENV["MAIL_DELIVERY_METHOD"].try(:to_sym) || :letter_opener
  config.action_mailer.perform_deliveries = true

  # Not needed unless ENV["MAIL_DELIVERY_METHOD"] is defined
  config.action_mailer.smtp_settings = {
    address: ENV.fetch("SMTP_ADDRESS", ''),
    port: ENV.fetch("SMTP_PORT", '').to_i,
    user_name: ENV.fetch("SMTP_USERNAME", ''),
    password: ENV.fetch("SMTP_PASSWORD", ''),
    authentication: ENV.fetch("SMTP_AUTHENTICATION", '').to_sym,
    enable_starttls_auto: truthy_env_var?(ENV.fetch("SMTP_ENABLE_STARTTLS", ''))
  }

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true
  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger = ActiveSupport::TaggedLogging.new(logger)
  end

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker
  config.hosts << "ams.test"
end
