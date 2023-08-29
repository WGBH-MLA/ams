# frozen_string_literal: true
unless App.rails_5_1?
  
  # Generated via
  #  `rails generate hyrax:work_resource PhysicalInstantiationResource`
  require 'rails_helper'
  require 'hyrax/specs/shared_specs/indexers'
  
  RSpec.describe PhysicalInstantiationResourceIndexer do
    let(:indexer_class) { described_class }
    let(:resource) { PhysicalInstantiationResource.new }
  
    it_behaves_like 'a Hyrax::Resource indexer'
  end
end
