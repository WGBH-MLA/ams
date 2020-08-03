module DisabledFields
  extend ActiveSupport::Concern
  included do |base|
    class_attribute :disabled_fields, :readonly_fields, :hidden_fields
    self.disabled_fields = []
    self.readonly_fields = []
    self.hidden_fields   = []
    delegate :errors, to: :model

    base.extend FieldState
  end

  module FieldState
    def disabled?(field)
      self.disabled_fields.include?(field)
    end
    def readonly?(field)
      self.readonly_fields.include?(field) && self.send(field).present?
    end
    def hidden?(field)
      self.hidden_fields.include?(field)
    end
  end
end

