# Generated via
#  `rails generate hyrax:work Series`
require 'rails_helper'

RSpec.describe Hyrax::SeriesForm do

  let(:model) { build(:series) }
  let(:user) { build(:user) }
  let(:ability) { Ability.new(user) }
  let(:controller) { instance_double(Hyrax::SeriesController) }
  subject { described_class.new(model, ability, controller) }

  describe '#terms' do
    let :expected_terms do
      [
        :title,
        :creator,
        :description,
        :audience_level,
        :audience_rating,
        :annotation,
        :rights_summary,
        :rights_link,
        :representative_id,
        :thumbnail_id,
        :files,
        :visibility_during_embargo,
        :embargo_release_date,
        :visibility_after_embargo,
        :visibility_during_lease,
        :lease_expiration_date,
        :visibility_after_lease,
        :visibility,
        :rendering_ids,
        :ordered_member_ids,
        :in_works_ids,
        :member_of_collection_ids,
        :admin_set_id
      ]
    end

    it 'matches the set of expected terms' do
      expect(Set.new(subject.terms)).to eq Set.new(expected_terms)
    end
  end

  describe '#required_fields' do
    let(:required_fields) { [ :title, :description ] }
    it 'matches the set of required fields' do
      expect(Set.new(subject.required_fields)).to eq Set.new(required_fields)
    end
  end
end
