require 'rails_helper'

RSpec.describe Push do
  describe 'validation' do
    let(:assets) { create_list(:asset, rand(2..4)) }
    let(:asset_ids) { assets.map(&:id) }
    let(:invalid_ids) { [ 'cpb-aacip-11111111111', 'blerg'] }
    let(:pushed_ids) { [] } # overwrite in contexts below

    subject { build(:push, pushed_id_csv: pushed_ids.join(',')) }

    context 'when all IDs are well formed and exist in the repository' do
      let(:pushed_ids) { asset_ids }
      it 'is valid' do
        expect(subject).to be_valid
      end
    end

    context 'when some IDs do not exist in the repository' do
      let(:pushed_ids) { asset_ids + invalid_ids }
      let(:error_messages) { subject.errors[:pushed_id_csv].join("\n") }

      before { subject.validate }

      it 'is not valid and has errors on the :pushed_id_csv field indicating ' \
         'which IDs are not in the repository' do
        # Shouldn't be valid
        expect(subject).not_to be_valid
        # Error message should contain all the bad IDs.
        invalid_ids.each do |missing_id|
          expect(error_messages).to include missing_id
        end
        # Error message should NOT contain any IDs that should be found.
        asset_ids.each do |asset_id|
          expect(error_messages).not_to include asset_id
        end
      end
    end
  end
end
