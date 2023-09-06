# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work_resource DigitalInstantiationResource`
class DigitalInstantiationResource < Hyrax::Work
  include Hyrax::Schema(:basic_metadata)
  include Hyrax::Schema(:digital_instantiation_resource)
  include AMS::WorkBehavior

  self.valid_child_concerns = [EssenceTrackResource]

end
