# frozen_string_literal: true

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rails/all'
require 'rspec/rails'
require 'action_view'
require 'spec_helper'
require 'devise'
require 'devise/version'
require 'noid/rails/rspec'
require 'rspec/matchers'
require 'capybara/rspec'
require 'capybara-screenshot/rspec'
require 'selenium/webdriver'
require 'capybara/rails'
require 'ams'
require 'webdrivers'
require "deprecation_toolkit/rspec"

# Require support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }
require_relative 'support/controller_macros'

ActiveRecord::Migration.maintain_test_schema!

# See https://github.com/thoughtbot/shoulda-matchers#rspec
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

# Disable automatic screenshots on failure if ENV var says so.
if [false, 'false', '0', 0].include? ENV['AUTO_SCREENSHOTS'].to_s.downcase
  Capybara::Screenshot.autosave_on_failure = false
end

ENV['WEB_HOST'] ||= `hostname -s`.strip
if ENV['CHROME_HOSTNAME'].present?
  # Uses faster rack_test driver when JavaScript support not needed
  Capybara.default_max_wait_time = 8
  # Capybara.default_driver = :rack_test

  if App.rails_5_1?
    capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
      chromeOptions: {
        args: %w[disable-gpu no-sandbox whitelisted-ips window-size=1400,1400]
      }
    )

    Capybara.register_driver :chrome do |app|
      d = Capybara::Selenium::Driver.new(app,
                                        browser: :remote,
                                        desired_capabilities: capabilities,
                                        url: "http://#{ENV['CHROME_HOSTNAME']}:4444/wd/hub")
      # Fix for capybara vs remote files. Selenium handles this for us
      d.browser.file_detector = lambda do |args|
        str = args.first.to_s
        str if File.exist?(str)
      end
      d
    end
  else
    chrome_options = Selenium::WebDriver::Chrome::Options.new(
      args: %w[--disable-gpu --no-sandbox --whitelisted-ips --window-size=1400,1400]
    )

    Capybara.register_driver :chrome do |app|
      d = Capybara::Selenium::Driver.new(app,
                                         browser: :remote,
                                         options: chrome_options,
                                         url: "http://#{ENV['CHROME_HOSTNAME']}:4444/wd/hub")
      # Fix for capybara vs remote files. Selenium handles this for us
      d.browser.file_detector = lambda do |args|
        str = args.first.to_s
        str if File.exist?(str)
      end
      d
    end
  end
  Capybara.server_host = '0.0.0.0'
  Capybara.server_port = 3001
  Capybara.app_host = "http://#{ENV['WEB_HOST']}:#{Capybara.server_port}"
else
  # Set the capybara JS driver to whatever was passed in to JS_DRIVER,
  # defaulting to :selenium_chrome_headless
  Capybara.javascript_driver = ENV.fetch('JS_DRIVER', 'selenium_chrome_headless').to_sym

  Capybara.register_driver :chrome do |app|
    Capybara::Selenium::Driver.new(
      app,
      browser: :chrome,
    )
  end
end

Capybara.javascript_driver = :chrome

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = false
  config.infer_spec_type_from_file_location!

  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Capybara::RSpecMatchers, type: :input
  config.include Warden::Test::Helpers, type: :feature
  config.after(:each, type: :feature) { Warden.test_reset! }

  config.include Capybara::DSL

  # Gets around a bug in RSpec where helper methods that are defined in views aren't
  # getting scoped correctly and RSpec returns "does not implement" errors. So we
  # can disable verify_partial_doubles if a particular test is giving us problems.
  # Ex:
  #   describe "problem test", verify_partial_doubles: false do
  #     ...
  #   end
  config.before :each do |example|
    config.mock_with :rspec do |mocks|
      mocks.verify_partial_doubles = example.metadata.fetch(:verify_partial_doubles, true)
    end
  end

  config.before :suite do
    # Reset data before the suite is run.
    AMS.reset_data!
  end

  # Reset data conditionally for each exampld; defaults to true.
  config.before :each do |example|
    AMS.reset_data! if example.metadata.fetch(:reset_data, true)
  end

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  # For Devise >= 4.1.0
  config.extend ControllerMacros, :type => :controller

  # dual boot support
  config.include SolrHelper
end

# Uncomment this to specify a version of ChromeDriver, a list of which can be
# found at https://chromedriver.storage.googleapis.com/index.html.
# NOTE: The ChromeDriver version must be compatible with the version of Chrome,
# being used to run tests, whether it's in development or on Travis CI.
# NOTE: The 'webdrivers' gem is supposed to automatically select the correct
# version of ChromeDriver, so you should only need to use this if WebDrivers is
# failing to do so.
# Webdrivers::Chromedriver.required_version = ''

# Uncomment this to help debug ChromeDriver (or other web driver) issues on
# Travis or development.
# Webdrivers.logger.level = :DEBUG
