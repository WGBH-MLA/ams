# frozen_string_literal: true
  
# Generated via
#  `rails generate hyrax:work_resource AssetResource`
class AssetResource < Hyrax::Work
  include Hyrax::Schema(:basic_metadata)
  include Hyrax::Schema(:asset_resource)
end
