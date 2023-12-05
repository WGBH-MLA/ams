# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work_resource EssenceTrackResource`
class EssenceTrackResource < Hyrax::Work
  include Hyrax::Schema(:basic_metadata)
  include Hyrax::Schema(:essence_track_resource)
  include AMS::WorkBehavior

  self.valid_child_concerns = []

end
