# frozen_string_literal: true

# OVERRIDE Hyrax to fix Ruby 3.0+ argument compatibility in Hyrax::ArResource
# FactoryBot may pass positional arguments to save, but ArResource#save only accepts keyword arguments
# In Ruby 3.0+, positional and keyword arguments are strictly separated
#
# This must be in an initializer to ensure it loads before FactoryBot resolves methods during test setup.

Rails.application.config.after_initialize do
  Hyrax::ArResource.module_eval do
    # Alias the original save method so we can call it
    alias_method :original_ar_resource_save, :save

    # Override save to accept positional arguments (and ignore them) for FactoryBot compatibility
    # FactoryBot's create strategy may pass positional arguments that the original method doesn't accept
    # Forward keyword arguments to preserve the original behavior
    def save(*_positional_args, persister: Hyrax.persister, index_adapter: Hyrax.index_adapter, user: ::User.system_user)
      original_ar_resource_save(persister: persister, index_adapter: index_adapter, user: user)
    end

    # Alias the original save! method
    alias_method :original_ar_resource_save!, :save!

    # Override save! to accept positional arguments (and ignore them) for FactoryBot compatibility
    # Forward keyword arguments to preserve the original behavior
    def save!(*_positional_args, **opts)
      original_ar_resource_save!(**opts)
    end
  end
end
