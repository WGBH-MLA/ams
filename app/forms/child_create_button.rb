module ChildCreateButton
  extend ActiveSupport::Concern
  included do
    class_attribute :child_create_button
    self.child_create_button = true
  end
end

