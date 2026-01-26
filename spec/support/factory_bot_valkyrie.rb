# frozen_string_literal: true

# Configure FactoryBot to use Valkyrie persister for resource classes
# This fixes Ruby 3.0+ compatibility issues with Hyrax::ArResource#save
# which doesn't accept positional arguments but FactoryBot may pass them

# Force load Hyrax::ArResource so we can patch it
require 'hyrax/ar_resource'

# Module to prepend to Hyrax::ArResource to fix argument handling
module ArResourceSaveArgumentFix
  # Override save to accept positional arguments (ignore them) and forward keyword args
  def save(*_args, persister: Hyrax.persister, index_adapter: Hyrax.index_adapter, user: ::User.system_user)
    super(persister: persister, index_adapter: index_adapter, user: user)
  end

  # Override save! to accept positional arguments (ignore them) and forward keyword args
  def save!(*_args, **opts)
    super(**opts)
  end
end

# Prepend the fix to Hyrax::ArResource immediately
Hyrax::ArResource.prepend(ArResourceSaveArgumentFix)

# Also patch the FactoryBot create strategy as a belt-and-suspenders approach
module FactoryBotValkyrieStrategy
  def result(evaluation)
    evaluation.object.tap do |instance|
      evaluation.notify(:after_build, instance)

      # Use Valkyrie persister for Valkyrie resources instead of calling save!
      if instance.is_a?(Valkyrie::Resource)
        # Save to persistence layer
        result = Hyrax.persister.save(resource: instance)
        # Index to Solr (this is what ArResource#save also does)
        Hyrax.index_adapter.save(resource: result)
        # Update the instance with the persisted ID
        instance.id = result.id if result.respond_to?(:id)
      elsif @to_create
        # Use custom to_create callback if defined
        @to_create.call(instance, evaluation)
      elsif instance.respond_to?(:save!)
        # Default FactoryBot behavior
        instance.save!
      elsif instance.respond_to?(:save)
        # Try save without bang
        instance.save
      end
      # If none of the above, the object doesn't need persisting (e.g., PBCore::DescriptionDocument)

      evaluation.notify(:after_create, instance)
    end
  end
end

# Apply the patch to FactoryBot's create strategy
FactoryBot::Strategy::Create.prepend(FactoryBotValkyrieStrategy)
