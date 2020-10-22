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

  context "delegation" do
    let(:solr_doc) { instance_double(SolrDocument) }
    subject { described_class.new(solr_doc, nil) }

    let(:expected_delegated_methods) { [ :title, :genre, :asset_types,
      :broadcast_date, :created_date, :episode_number, :description,
      :spatial_coverage, :temporal_coverage, :audience_level, :audience_rating,
      :annotation, :rights_summary, :rights_link, :date, :local_identifier,
      :pbs_nola_code, :eidr_id, :topics, :subject, :program_title,
      :episode_title, :segment_title, :raw_footage_title, :promo_title,
      :clip_title, :program_description, :episode_description,
      :segment_description, :raw_footage_description, :promo_description,
      :clip_description, :copyright_date, :level_of_user_access, :outside_url,
      :special_collections, :transcript_status, :sonyci_id, :licensing_info,
      :cataloging_status, :canonical_meta_tag, :special_collection_category,
      :playlist_group, :playlist_order, :organization
    ] }

    it 'delegates methods to :solr_document' do
      expected_delegated_methods.each do |expected_delegated_method|
        expect(subject).to delegate_method(expected_delegated_method).to :solr_document
      end
    end
  end

  describe '#last_pushed' do
    let(:solr_doc) { instance_double(SolrDocument) }
    let(:timestamp) { Time.new(2020, 9, 15, 5, 10, 15, "+00:00").strftime('%s') }
    subject { described_class.new(solr_doc, nil) }
    before { allow(solr_doc).to receive(:[]).with('last_pushed').and_return(timestamp.to_i) }
    it 'converts a Unix timestamp into a readable EDT date string with time zone' do
      expect(subject.last_pushed).to eq '09-15-20 01:10 EDT'
    end
  end
end
