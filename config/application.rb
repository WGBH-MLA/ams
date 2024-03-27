require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
groups = Rails.groups
groups += ['bulkrax']
Bundler.require(*groups)


Dotenv::Railtie.load

HOSTNAME = ENV['HOSTNAME']

module AMS
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Sets the max allowed results in any export.
    config.max_export_limit = 9_999_999

    # Sets the max allowed results for a browser download.
    config.max_export_to_browser_limit = 1000

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Don't generate system test files.
    config.generators.system_tests = nil

    config.to_prepare do
      # Allows us to use decorator files, which change methods or behavior on upstream classes
      # with minimal overrides or fuss. Pattern adapted from Spree and Refinery projects
      Dir.glob(File.join(File.dirname(__FILE__), "../app/**/*_decorator*.rb")).sort.each do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end

      Dir.glob(File.join(File.dirname(__FILE__), "../lib/**/*_decorator*.rb")).sort.each do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end
  end
end

module App
  # Returns true if the current Rails version is 6.0.x
  def self.rails_5_1?
    Rails.version.start_with? '5.1'
  end
end
