# Generated via
#  `rails generate hyrax:work Series`
require 'rails_helper'

RSpec.describe ::SeriesCollectionFormOverrides do

  it 'is prepended on to Hyrax::Forms::CollectionForm' do
    expect(Hyrax::Forms::CollectionForm).to have_prepended ::SeriesCollectionFormOverrides
  end


  let(:series_collection) { build(:series_collection) }
  let(:user) { build(:user) }
  let(:ability) { Ability.new(user) }
  let(:controller) { instance_double(Hyrax::CollectionsController) }
  subject { Hyrax::Forms::CollectionForm.new(series_collection, ability, controller) }

  describe '#terms' do
    let :expected_terms do
      [
        :series_title,
        :series_description,
        :series_annotation,
        :series_pbs_nola_code,
        :series_eidr_id,
        :series_start_date,
        :series_end_date
      ]
    end

    it 'matches the set of expected terms' do
      expect(Set.new(subject.terms)).to eq Set.new(expected_terms)
    end
  end

  describe '#required_fields' do
    let(:required_fields) { [ :series_title ] }
    it 'matches the set of required fields' do
      expect(Set.new(subject.required_fields)).to eq Set.new(required_fields)
    end
  end
end
