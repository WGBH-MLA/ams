# frozen_string_literal: true

# Fix Ruby 3.0+ compatibility with FactoryBot and Hyrax::ArResource#save
#
# Problem: Hyrax::ArResource#save only accepts keyword arguments, but FactoryBot
# may pass positional arguments, causing ArgumentError in Ruby 3.0+
#
# Solution: Multiple-layered approach to intercept save calls

# Define the fix module that strips positional arguments
module HyraxSaveArgumentFix
  def save(*_args, **kwargs)
    super(**kwargs)
  end

  def save!(*_args, **kwargs)
    super(**kwargs)
  end
end

# List of resource classes to patch
VALKYRIE_RESOURCE_CLASSES = %w[
  AssetResource
  DigitalInstantiationResource
  PhysicalInstantiationResource
  EssenceTrackResource
  ContributionResource
].freeze

# Apply patches to all resource classes
VALKYRIE_RESOURCE_CLASSES.each do |class_name|
  begin
    klass = class_name.constantize
    unless klass.ancestors.include?(HyraxSaveArgumentFix)
      klass.prepend(HyraxSaveArgumentFix)
    end
  rescue NameError
    # Class not loaded yet
  end
end

# Patch FactoryBot::Evaluator#method_missing to handle Hyrax::ArResource methods
# that only accept keyword arguments (save, save!, create, create!, update, update!)
module FactoryBotEvaluatorSaveFix
  # Methods in Hyrax::ArResource that only accept keyword arguments
  KEYWORD_ONLY_METHODS = [:save, :save!, :create, :create!, :update, :update!].freeze

  def method_missing(method_name, *args, &block)
    method_sym = method_name.to_sym

    if @instance.respond_to?(method_name)
      # For Hyrax::ArResource methods that only accept kwargs, strip positional args
      # (create/update are aliased to save in ArResource)
      if KEYWORD_ONLY_METHODS.include?(method_sym)
        return method_sym.to_s.end_with?('!') ? @instance.save! : @instance.save
      end
      @instance.public_send(method_name, *args, &block)
    else
      FactoryBot::SyntaxRunner.new.send(method_name, *args, &block)
    end
  end
end

# Apply to FactoryBot::Evaluator
if defined?(FactoryBot::Evaluator)
  FactoryBot::Evaluator.prepend(FactoryBotEvaluatorSaveFix)
end

# Patch FactoryBot's create strategy to use Valkyrie persister directly
# This ensures Valkyrie resources are saved correctly
module FactoryBotValkyrieStrategy
  def result(evaluation)
    evaluation.object.tap do |instance|
      evaluation.notify(:after_build, instance)

      if defined?(Valkyrie::Resource) && instance.is_a?(Valkyrie::Resource)
        result = Hyrax.persister.save(resource: instance)
        Hyrax.index_adapter.save(resource: result)
        instance.id = result.id if result.respond_to?(:id)
      elsif @to_create
        @to_create.call(instance, evaluation)
      elsif instance.respond_to?(:save!)
        instance.save!
      elsif instance.respond_to?(:save)
        instance.save
      end

      evaluation.notify(:after_create, instance)
    end
  end
end

FactoryBot::Strategy::Create.prepend(FactoryBotValkyrieStrategy)
