# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work_resource ContributionResource`
class ContributionResource < Hyrax::Work
  include Hyrax::Schema(:basic_metadata)
  include Hyrax::Schema(:contribution_resource)
end
