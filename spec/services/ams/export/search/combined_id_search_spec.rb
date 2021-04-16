require 'rails_helper'

RSpec.describe AMS::Export::Search::CombinedIDSearch do
  let(:user) { create(:user) }
  let(:max_ids) { AMS::Export::Search::IDSearch::MAX_IDS_PER_QUERY }
  # Create a list of fake IDs that is a few times larger than the max allowed
  # IDS per query, plus a few more.
  let(:ids) do
    ( max_ids * rand(2..4) + rand(1..10) ).times.map { SecureRandom.uuid }
  end

  # The exepcted number of IDSearch objects within the CombinedIDSearch should
  # be the total number of IDs divided by the max per query, plus 1 for the
  # remainder.
  let(:expected_id_search_count) { ( ids.count / max_ids ).to_i + 1 }

  subject { described_class.new(ids: ids, user: user) }

  describe '#searches' do
    it 'returns IDSearch instances containing slices of the IDs.' do
      expect(subject.searches).to all( be_a AMS::Export::Search::IDSearch )
      expect(subject.searches.count).to eq expected_id_search_count
      expect(subject.searches.map(&:ids).flatten).to eq ids
    end
  end
end
