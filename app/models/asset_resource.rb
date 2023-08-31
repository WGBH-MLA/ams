# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work_resource AssetResource`
class AssetResource < Hyrax::Work
  include Hyrax::Schema(:basic_metadata)
  include Hyrax::Schema(:asset_resource)

  # override valk definition to make sure the internal_resource name stays the same no matter
  # how the record was created
  attribute :internal_resource, Valkyrie::Types::Any.default(self.name.gsub(/Resource$/,'').freeze), internal: true
end
