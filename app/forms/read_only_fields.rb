module ReadOnlyFields
  extend ActiveSupport::Concern
  included do
    class_attribute :readonly_fields
    self.readonly_fields = []
    delegate :errors, to: :model
  end

  def readonly?(field)
    self.readonly_fields.include?(field)
  end
end

