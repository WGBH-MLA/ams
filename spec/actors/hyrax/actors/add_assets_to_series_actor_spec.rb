require 'rails_helper'

RSpec.describe Hyrax::Actors::AddAssetsToSeriesActor do
  let(:ability) { ::Ability.new(depositor) }
  let(:env) { Hyrax::Actors::Environment.new(series, ability, attributes) }
  let(:terminator) { Hyrax::Actors::Terminator.new }
  let(:depositor) { create(:user) }
  let(:series) { create(:series) }
  let(:attributes) { HashWithIndifferentAccess.new(series_assets_attributes: { '0' => { id: id } }) }

  subject(:middleware) do
    stack = ActionDispatch::MiddlewareStack.new.tap do |middleware|
      middleware.use described_class
    end
    stack.build(terminator)
  end

  describe "#update" do
    subject { middleware.update(env) }

    before do
      series.assets << existing_child_asset
    end
    let(:existing_child_asset) { create(:asset) }
    let(:id) { existing_child_asset.id }

    context "without useful attributes" do
      let(:attributes) { {} }

      it { is_expected.to be true }
    end

    context "when the id already exists in the assets" do
      it "does nothing" do
        expect { subject }.not_to change { series.assets.to_a }
      end

      context "and the _destroy flag is set" do
        let(:attributes) { HashWithIndifferentAccess.new(series_assets_attributes: { '0' => { id: id, _destroy: 'true' } }) }

        it "removes from the member and the ordered assets" do
          expect { subject }.to change { series.assets.to_a }
          expect(series.asset_ids).not_to include(existing_child_asset.id)
          expect(series.asset_ids).not_to include(existing_child_asset.id)
        end
      end
    end

    context "when the id does not exist in the assets" do
      let(:another_asset) { create(:asset) }
      let(:id) { another_asset.id }

      it "is added to the assets" do
        expect { subject }.to change { series.assets.to_a }
        expect(series.asset_ids).to include(existing_child_asset.id, another_asset.id)
      end
    end
  end
end