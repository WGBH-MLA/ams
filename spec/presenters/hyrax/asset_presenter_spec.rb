# Generated via
#  `rails generate hyrax:work Asset`
require 'rails_helper'

RSpec.describe Hyrax::AssetPresenter do
  let(:request) { double(host: 'example.org', base_url: 'http://example.org') }
  let(:ability) { Ability.new(build(:user)) }
  let(:rows) { 10 }
  let(:page) { 1 }

  context "asset_members" do
    describe "list_of_contribution_ids_to_display" do
      subject { presenter }
      let(:asset) { create(:asset) }
      let(:presenter) do
        described_class.new(SolrDocument.new(asset.to_solr), ability, request)
      end
      let(:contribution) { create(:contribution) }
      let(:contribution_ids) { [contribution.id] }
      before do
        allow(presenter).to receive(:rows_from_params).and_return(rows)
        allow(presenter).to receive(:current_page).and_return(page)
      end

      it "returns empty array" do
        expect(asset.members).to eq []
        expect(presenter.list_of_contribution_ids_to_display).to eq []
      end

      it "returns contribution member ids" do
        asset.ordered_members << contribution
        expect(asset.save).to eq true
        expect(asset.members.to_a.size).to eq 1
        expect(presenter.list_of_contribution_ids_to_display.sort).to eq contribution_ids.sort
      end
    end

    describe "list_of_instantiation_ids_to_display" do
      subject { presenter }
      let(:asset) { create(:asset) }
      let(:presenter) do
        described_class.new(SolrDocument.new(asset.to_solr), ability, request)
      end
      let(:digital_instantiation) { create(:digital_instantiation) }
      let(:physical_instantiation) { create(:physical_instantiation) }
      let(:instantiation_ids) { [digital_instantiation.id, physical_instantiation.id] }

      before do
        allow(presenter).to receive(:rows_from_params).and_return(rows)
        allow(presenter).to receive(:current_page).and_return(page)
      end

      it "returns empty array" do
        expect(asset.members).to eq []
        expect(presenter.list_of_instantiation_ids_to_display).to eq []
      end

      it "returns instantiation member ids" do
        asset.ordered_members << digital_instantiation
        asset.ordered_members << physical_instantiation
        asset.save
        expect(asset.members.to_a.size).to eq 2
        expect(presenter.list_of_instantiation_ids_to_display.sort).to eq instantiation_ids.sort
      end
    end

    describe "filter_item_ids_to_display" do
      subject { presenter }
      let(:asset) { create(:asset) }
      let(:presenter) do
        described_class.new(SolrDocument.new(asset.to_solr), ability, request)
      end
      let(:query) { "(has_model_ssim:DigitalInstantiation OR has_model_ssim:PhysicalInstantiation) " }
      let(:digital_instantiation) { create(:digital_instantiation) }
      let(:physical_instantiation) { create(:physical_instantiation) }
      let(:instantiation_ids) { [digital_instantiation.id, physical_instantiation.id] }

      before do
        allow(presenter).to receive(:rows_from_params).and_return(rows)
        allow(presenter).to receive(:current_page).and_return(page)
      end

      it "returns empty array" do
        expect(presenter.list_of_item_ids_to_display).to eq []
        expect(asset.members).to eq []
        expect(presenter.filter_item_ids_to_display(query)).to eq []
      end

      it "returns instantiation member ids" do
        asset.ordered_members << digital_instantiation
        asset.ordered_members << physical_instantiation
        asset.save
        expect(presenter.filter_item_ids_to_display(query).sort).to eq instantiation_ids.sort
      end
    end

    describe "display_aapb_admin_data?" do
      subject { presenter }
      let(:asset) { create(:asset) }
      let(:presenter) do
        described_class.new(SolrDocument.new(asset.to_solr), ability, request)
      end
      let(:admin_data_attr) { attributes_for(:admin_data) }

      it "returns true when any AAPBAdmin Data attribute is not blank" do
        # defaul asset have admin data
        expect(asset.admin_data[:sonyci_id]).to eq admin_data_attr[:sonyci_id]
        expect(presenter.display_aapb_admin_data?).to eq true
      end

      it "returns false when all AAPBAdmin Data attributes are empty" do
        asset.admin_data[:sonyci_id] = []
        asset.save
        expect(presenter.display_aapb_admin_data?).to eq false
      end
    end
  end

  context "delegate_methods" do
    subject { presenter }
    let(:asset) { create(:asset) }

    let(:presenter) do
      described_class.new(SolrDocument.new(asset.to_solr), nil)
    end

    # If the fields require no addition logic for display, you can simply delegate
    # them to the solr document
    it { is_expected.to delegate_method(:title).to(:solr_document) }
    it { is_expected.to delegate_method(:genre).to(:solr_document) }
    it { is_expected.to delegate_method(:asset_types).to(:solr_document) }
    it { is_expected.to delegate_method(:broadcast_date).to(:solr_document) }
    it { is_expected.to delegate_method(:created_date).to(:solr_document) }
    it { is_expected.to delegate_method(:episode_number).to(:solr_document) }
    it { is_expected.to delegate_method(:description).to(:solr_document) }
    it { is_expected.to delegate_method(:spatial_coverage).to(:solr_document) }
    it { is_expected.to delegate_method(:temporal_coverage).to(:solr_document) }
    it { is_expected.to delegate_method(:audience_level).to(:solr_document) }
    it { is_expected.to delegate_method(:audience_rating).to(:solr_document) }
    it { is_expected.to delegate_method(:annotation).to(:solr_document) }
    it { is_expected.to delegate_method(:rights_summary).to(:solr_document) }
    it { is_expected.to delegate_method(:rights_link).to(:solr_document) }
    it { is_expected.to delegate_method(:date).to(:solr_document) }
    it { is_expected.to delegate_method(:local_identifier).to(:solr_document) }
    it { is_expected.to delegate_method(:pbs_nola_code).to(:solr_document) }
    it { is_expected.to delegate_method(:eidr_id).to(:solr_document) }
    it { is_expected.to delegate_method(:topics).to(:solr_document) }
    it { is_expected.to delegate_method(:subject).to(:solr_document) }
    it { is_expected.to delegate_method(:program_title).to(:solr_document) }
    it { is_expected.to delegate_method(:episode_title).to(:solr_document) }
    it { is_expected.to delegate_method(:segment_title).to(:solr_document) }
    it { is_expected.to delegate_method(:raw_footage_title).to(:solr_document) }
    it { is_expected.to delegate_method(:promo_title).to(:solr_document) }
    it { is_expected.to delegate_method(:clip_title).to(:solr_document) }
    it { is_expected.to delegate_method(:program_description).to(:solr_document) }
    it { is_expected.to delegate_method(:episode_description).to(:solr_document) }
    it { is_expected.to delegate_method(:segment_description).to(:solr_document) }
    it { is_expected.to delegate_method(:raw_footage_description).to(:solr_document) }
    it { is_expected.to delegate_method(:promo_description).to(:solr_document) }
    it { is_expected.to delegate_method(:clip_description).to(:solr_document) }
    it { is_expected.to delegate_method(:copyright_date).to(:solr_document) }
    it { is_expected.to delegate_method(:level_of_user_access).to(:solr_document) }
    it { is_expected.to delegate_method(:minimally_cataloged).to(:solr_document) }
    it { is_expected.to delegate_method(:outside_url).to(:solr_document) }
    it { is_expected.to delegate_method(:special_collections).to(:solr_document) }
    it { is_expected.to delegate_method(:transcript_status).to(:solr_document) }
    it { is_expected.to delegate_method(:sonyci_id).to(:solr_document) }
    it { is_expected.to delegate_method(:licensing_info).to(:solr_document) }
    it { is_expected.to delegate_method(:cataloging_status).to(:solr_document) }
    it { is_expected.to delegate_method(:canonical_meta_tag).to(:solr_document) }
    it { is_expected.to delegate_method(:special_collection_category).to(:solr_document) }
    it { is_expected.to delegate_method(:playlist_group).to(:solr_document) }
    it { is_expected.to delegate_method(:playlist_order).to(:solr_document) }
    it { is_expected.to delegate_method(:organization).to(:solr_document) }
  end
end
