class ApplicationJob < ActiveJob::Base
  # Convenience method for grabbing named arguments passed to the #perform
  # method.
  # @return [Hash] hash of named arguments if any were passed; an empty hash
  #   if none were passed.
  def named_arguments
    @named_arguments ||= if arguments.last.is_a? Hash
      arguments.last
    else
      {}
    end
  end
end
