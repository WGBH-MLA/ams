# frozen_string_literal: true

# OVERRIDE Hyrax to fix Ruby 3.2+ keyword argument compatibility in Hyrax::ArResource
# The original save method doesn't accept keyword arguments, but save! may pass them
# In Ruby 3.2+, keyword arguments are strictly separated from positional arguments

module Hyrax
  module ArResourceDecorator
    # Override save to accept and ignore keyword arguments for Ruby 3.2+ compatibility
    # ActiveRecord's save! calls save with options, but ArResource#save doesn't accept them
    def save(*args, **_options)
      # Call original save without arguments
      args.empty? ? super() : super()
    end

    # Override save! to accept keyword arguments for Ruby 3.2+ compatibility
    def save!(*args, **options)
      save(*args, **options) || raise(ActiveRecord::RecordNotSaved.new("Failed to save the record", self))
    end
  end
end

Hyrax::ArResource.prepend(Hyrax::ArResourceDecorator)
