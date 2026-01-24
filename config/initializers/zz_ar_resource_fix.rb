# frozen_string_literal: true

# OVERRIDE Hyrax to fix Ruby 3.0+ argument compatibility in Hyrax::ArResource
# FactoryBot may pass positional arguments to save, but ArResource#save only accepts keyword arguments
# In Ruby 3.0+, positional and keyword arguments are strictly separated
#
# This file is named 'zz_' to ensure it loads after Hyrax is fully initialized

module ArResourceArgumentFix
  # Override save to accept positional arguments (and ignore them) for FactoryBot compatibility
  # FactoryBot's create strategy may pass positional arguments that the original method doesn't accept
  # Forward keyword arguments to preserve the original behavior
  def save(*_positional_args, persister: Hyrax.persister, index_adapter: Hyrax.index_adapter, user: ::User.system_user)
    super(persister: persister, index_adapter: index_adapter, user: user)
  end

  # Override save! to accept positional arguments (and ignore them) for FactoryBot compatibility
  # Forward keyword arguments to preserve the original behavior
  def save!(*_positional_args, **opts)
    super(**opts)
  end
end

# Prepend to Hyrax::ArResource so all including classes get the fix
if defined?(Hyrax::ArResource)
  Hyrax::ArResource.prepend(ArResourceArgumentFix)
  Rails.logger.info "ArResourceArgumentFix prepended to Hyrax::ArResource" if defined?(Rails.logger)
end
