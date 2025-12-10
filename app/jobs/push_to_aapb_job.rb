require 'ams/export'

class PushToAAPBJob < ApplicationJob
  queue_as :push_to_aapb

  rescue_from StandardError do |error|
    Rails.logger.error "#{error.class}: #{error.message}\n\nBacktrace:\n#{error.backtrace.join("\n")}"
    failure_notification.send_failure(error_message: error.message)
  rescue StandardError => secondary_error
    # Double rescue!! Sometimes the rescue_from block throws an error.
    # NOTE: Unrescued errors will be retried by Sidekiq, which we don't want to
    # do if there is no chance of success.
    Rails.logger.error "#{secondary_error.class}: #{secondary_error.message}\n\nBacktrace:\n#{secondary_error.backtrace.join("\n")}"
  end

  # Runs the search, compiles the results, and delivers them.
  # NOTE: named arguments to #perform are accessed in other methods via
  #   #named_arguments (see ApplicationJob#named_arguments).

  def perform(id:, user:, retry_count: 0, max_retries: 20)
    push = Push.find(id)

    if push.push_ids.present?
      delivery.deliver
      notification.send_success
    else
      # Check if the job has exceeded max retries
      if retry_count >= max_retries
        Rails.logger.error "Max retries exceeded for Push ID: #{id}"
        failure_notification.send_failure(error_message: "Max retries exceeded for Push ID: #{id}")
        return
      end

      # Calculate delay with a backoff
      delay = calculate_delay(retry_count)

      Rails.logger.info "Rescheduling Push ID: #{id}, retry: #{retry_count + 1}, delay: #{delay}s"

      PushToAAPBJob.set(wait: delay.seconds).perform_later(
          id: id,
          user: user,
          retry_count: retry_count + 1,
          max_retries: max_retries
      )
    end
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "Push not found: #{id}"
    failure_notification.send_failure(error_message: "Push #{id} not found")
    raise
  rescue StandardError => e
    Rails.logger.error "Error processing Push ID: #{id} - #{e.message}"
    failure_notification.send_failure(error_message: e.message)
    raise
  end


  private

    def calculate_delay(retry_count)
      [60 * (2 ** retry_count), 600].min # max 10 mins
    end

    def ids
      @ids ||= Push.find(named_arguments[:id]).push_ids
    end

    def delivery
      @delivery ||= AMS::Export::Delivery::AAPBDelivery.new(export_results: results)
    end

    def results
      @results ||= AMS::Export::Results::PBCoreZipResults.new(solr_documents: search.solr_documents)
    end

    def search
      @search ||= AMS::Export::Search::CombinedIDSearch.new(ids: ids, user: named_arguments[:user], model_class_name: 'Asset')
    end

    def notification
      @notification ||= AMS::Export::Notification::PushToAAPBNotification.new(user: named_arguments[:user], delivery: delivery)
    end

    # Notification without delivery dependency, used for failure notifications
    # that may occur before the delivery object can be created.
    def failure_notification
      @failure_notification ||= AMS::Export::Notification::PushToAAPBNotification.new(user: named_arguments[:user])
    end
end
