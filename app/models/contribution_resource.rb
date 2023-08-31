# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work_resource ContributionResource`
class ContributionResource < Hyrax::Work
  include Hyrax::Schema(:basic_metadata)
  include Hyrax::Schema(:contribution_resource)
  attribute :internal_resource, Valkyrie::Types::Any.default(self.name.gsub(/Resource$/,'').freeze), internal: true

end
