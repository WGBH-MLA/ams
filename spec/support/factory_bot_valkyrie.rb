# frozen_string_literal: true

# Configure FactoryBot to use Valkyrie persister for resource classes
# This fixes Ruby 3.0+ compatibility issues with Hyrax::ArResource#save
# which doesn't accept positional arguments but FactoryBot may pass them

# Patch FactoryBot's evaluator to handle Valkyrie resource save calls
module FactoryBotEvaluatorValkyriefix
  def method_missing(method_name, *args, &block)
    # Intercept save/save! calls for Valkyrie resources and strip positional args
    if %i[save save!].include?(method_name) && @instance.is_a?(Valkyrie::Resource)
      # Call save without positional arguments, only keyword args
      kwargs = args.last.is_a?(Hash) ? args.last : {}
      @instance.public_send(method_name, **kwargs)
    else
      super
    end
  end
end

# Apply the evaluator patch
FactoryBot::Evaluator.prepend(FactoryBotEvaluatorValkyriefix)

# Also patch the FactoryBot create strategy
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
