# frozen_string_literal: true
unless App.rails_5_1?
  
  # Generated via
  #  `rails generate hyrax:work_resource ContributionResource`
  class ContributionResource < Hyrax::Work
    include Hyrax::Schema(:basic_metadata)
    include Hyrax::Schema(:contribution_resource)
  end
end
