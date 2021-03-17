require 'ams/export'

class PushToAAPBJob < ApplicationJob
  queue_as :push_to_aapb
  #
  # before_perform do |_job|
  #
  #   require "pry"; binding.pry
  #
  #   user = named_arguments[:user]
  #   raise "Expected :user to be a User but '#{user.class}' was given" unless user.is_a? User
  # end

  rescue_from StandardError do |error|
    Rails.logger.error "#{error.class}: #{error.message}\n\nBacktrace:\n#{error.backtrace.join("\n")}"
    notification.send_failure(error_message: error.message)
  rescue => secondary_error
    # Double rescue!! Sometimes the rescue_from block throws an error.
    # NOTE: Unrescued errors will be retried by Sidekiq, which we don't want to
    # do if there is no chance of success.
    Rails.logger.error "#{secondary_error.class}: #{secondary_error.message}\n\nBacktrace:\n#{secondary_error.backtrace.join("\n")}"
  end

  # Runs the search, compiles the results, and delivers them.
  # NOTE: named arguments to #perform are accessed in other methods via
  #   #named_arguments (see ApplicationJob#named_arguments).
  def perform(ids:, user:)
    delivery.deliver
  end

  after_perform { notification.send_success }

  private

    def delivery
      @delivery ||= AMS::Export::Delivery::AAPBDelivery.new(export_results: results)
    end

    def results
      @results ||= AMS::Export::Results::PBCoreZipResults.new(solr_documents: search.solr_documents)
    end

    def search
      @search ||= AMS::Export::Search::CombinedIDSearch.new(ids: named_arguments[:ids], user: named_arguments[:user], model_class_name: 'Asset')
    end

    def notification
      @notification ||= AMS::Export::Notification::PushToAAPBNotification.new(user: named_arguments[:user], delivery: delivery)
    end
end
