# frozen_string_literal: true

# OVERRIDE Hyrax to fix Ruby 3.0+ argument compatibility in Hyrax::ArResource
# FactoryBot may pass positional arguments to save, but ArResource#save only accepts keyword arguments
# In Ruby 3.0+, positional and keyword arguments are strictly separated

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

# Prepend immediately to Hyrax::ArResource so all including classes get the fix
Hyrax::ArResource.prepend(ArResourceArgumentFix)
