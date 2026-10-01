class ApplicationJob < ActiveJob::Base
  # Convenience method for grabbing named arguments passed to the #perform
  # method.
  # @return [Hash] hash of named arguments, empty hash if none passed.
  def named_arguments
    @named_arguments ||= if arguments.last.is_a? Hash
      arguments.last
    else
      {}
    end
  end

  # Rescue from any unhandled exceptions calling a base handle_error method that
  # can be overidden in subclasses while still being able to call `super` to get
  # consistent error logging behavior.
  rescue_from(StandardError) do |error|
    handle_error(error: error)
  end

  # Error handler method called in rescue_from block in base
  # class. Overwite in subclasses to customize error handling. Call `super` in
  # subclasses handle_error to get default error logging.
  # @param error [StandardError] the error to log
  # @param reraise [Boolean] whether to re-raise the error after logging it.
  #   Re-raising will trigger Sidekiq to retry the job, if using Sidekiq.
  #   Default is false, since failed jobs typically will just fail again.
  # @return [void]
  # @raises [StandardError] re-raises the error if reraise is true.
  def handle_error(error:, reraise: false)
    log_error(error)
    raise error if reraise
  end

  # Logs an error message with the error class and message, and optionally the
  # backtrace if in development environment. Optionally re-raises the error after
  # logging it.
  # @param error [StandardError] the error to log
  # @return [void]
  def log_error(error)
    msg = "#{error.class}: #{error.message}"
    msg += "\n#{error.backtrace.join("\n")}" if Rails.env.development?
    Rails.logger.error msg
  end
end
