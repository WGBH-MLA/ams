# frozen_string_literal: true

# Configure FactoryBot to use Valkyrie persister for resource classes
# This fixes Ruby 3.0+ compatibility issues with Hyrax::ArResource#save
# which doesn't accept positional arguments but FactoryBot may pass them

# Patch the FactoryBot create strategy to handle Valkyrie resources
module FactoryBotValkyrieStrategy
  def result(evaluation)
    evaluation.object.tap do |instance|
      evaluation.notify(:after_build, instance)

      # Use Valkyrie persister for Valkyrie resources instead of calling save!
      if instance.is_a?(Valkyrie::Resource)
        Hyrax.persister.save(resource: instance)
      else
        # Fall back to default behavior for non-Valkyrie objects
        if @to_create
          @to_create.call(instance, evaluation)
        else
          instance.save!
        end
      end

      evaluation.notify(:after_create, instance)
    end
  end
end

# Apply the patch to FactoryBot's create strategy
FactoryBot::Strategy::Create.prepend(FactoryBotValkyrieStrategy)
