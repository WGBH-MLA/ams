# frozen_string_literal: true
unless App.rails_5_1?
  
  # Generated via
  #  `rails generate hyrax:work_resource EssenceTrackResource`
  class EssenceTrackResource < Hyrax::Work
    include Hyrax::Schema(:basic_metadata)
    include Hyrax::Schema(:essence_track_resource)
  end
end
