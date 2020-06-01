# Generated via
#  `rails generate hyrax:work Asset`
require 'rails_helper'

RSpec.describe AAPB::AttributeIndexedToParentPresenter do
  let(:request) { double(host: 'example.org', base_url: 'http://example.org') }
  let(:ability) { Ability.new(build(:user)) }
  let(:physical_instantiation) { create(:physical_instantiation) }
  let(:digital_instantiation) { create(:digital_instantiation) }

  let(:pi_presenter) { Hyrax::PhysicalInstantiationPresenter.new(SolrDocument.new(physical_instantiation.to_solr), ability, request) }
  let(:di_presenter) { Hyrax::DigitalInstantiationPresenter.new(SolrDocument.new(digital_instantiation.to_solr), ability, request) }

  context "PhysicalInstantiation" do
    it "#attribute_indexed_to_parent?" do
      expect(pi_presenter.attribute_indexed_to_parent?(:dimension, physical_instantiation.class)).to be false
      expect(pi_presenter.attribute_indexed_to_parent?(:format, physical_instantiation.class)).to be true
    end

    it "#attribute_facetable?" do
      expect(pi_presenter.attribute_facetable?(:alternative_modes, physical_instantiation.class)).to be false
      expect(pi_presenter.attribute_facetable?(:holding_organization, physical_instantiation.class)).to be true
    end
  end

  context "DigitalInstantiation" do
    it "#attribute_indexed_to_parent?" do
      expect(di_presenter.attribute_indexed_to_parent?(:standard, physical_instantiation.class)).to be false
      expect(di_presenter.attribute_indexed_to_parent?(:media_type, physical_instantiation.class)).to be true
    end

    it "#attribute_facetable?" do
      expect(di_presenter.attribute_facetable?(:alternative_modes, physical_instantiation.class)).to be false
      expect(di_presenter.attribute_facetable?(:holding_organization, physical_instantiation.class)).to be true
    end
  end
end