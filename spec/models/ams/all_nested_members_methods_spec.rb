require 'rails_helper'

RSpec.describe AMS::AllNestedMembersMethods do
  let(:asset) { create(:asset, :with_digital_instantiation_and_essence_track) }
  let(:digital_instantiation ) { asset.digital_instantiations.first }
  let(:essence_track_id) { digital_instantiation.member_ids.first }

  let(:nested_ids) { asset.all_nested_members.map(&:id).sort }

  context "an asset with nested members" do
    describe ".all_nested_members" do
      it "contains nested members" do
        # DigitalInstantiations are in the Asset members
        expect(nested_ids).to include(digital_instantiation.id)
        # EssenceTracks are in the DigitalInstantiation members
        expect(nested_ids).to include(essence_track_id)
      end
    end
  end
end