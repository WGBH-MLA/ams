module Bulkrax
  module ValkyrieObjectFactoryDecorator
    def permitted_attributes
      attributes.keys.map(&:to_sym)
    end
  end
end

Bulkrax::ValkyrieObjectFactory.prepend(Bulkrax::ValkyrieObjectFactoryDecorator)
