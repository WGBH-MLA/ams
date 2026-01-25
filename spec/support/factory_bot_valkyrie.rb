# frozen_string_literal: true

# Configure FactoryBot to use Valkyrie persister for resource classes
# This fixes Ruby 3.0+ compatibility issues with Hyrax::ArResource#save
# which doesn't accept positional arguments but FactoryBot may pass them

# Patch the FactoryBot create strategy to handle Valkyrie resources
module FactoryBotValkyrieStrategy
  def result(evaluation)
    evaluation.object.tap do |instance|
      evaluation.notify(:after_build, instance)

      # Use Valkyrie persister for Valkyrie resources instead of calling @to_create
      # which would call save! on the instance
      if instance.is_a?(Valkyrie::Resource)
        Hyrax.persister.save(resource: instance)
      else
        @to_create.call(instance, evaluation)
      end

      evaluation.notify(:after_create, instance)
    end
  end
end

# Apply the patch to FactoryBot's create strategy
FactoryBot::Strategy::Create.prepend(FactoryBotValkyrieStrategy)
