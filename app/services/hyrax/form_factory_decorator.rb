# frozen_string_literal: true

# OVERRIDE Hyrax 5.0rc1 to pass in ability and controller to form objects
module Hyrax
  module FormFactoryDecorator
    def build(model, ability, controller)
      form = Hyrax::Forms::ResourceForm.for(model)
      form.controller = controller
      form.current_ability = ability

      form.prepopulate!
    end
  end
end

Hyrax::FormFactory.prepend Hyrax::FormFactoryDecorator
