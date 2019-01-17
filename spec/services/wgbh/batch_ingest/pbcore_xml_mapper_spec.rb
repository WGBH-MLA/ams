require 'rails_helper'
require 'wgbh/batch_ingest/pbcore_xml_mapper'

RSpec.describe WGBH::BatchIngest::PBCoreXMLMapper, :pbcore_xpath_helper do
  describe '#asset_attributes' do
    let(:pbcore_xml) { build(:pbcore_description_document, :full_aapb).to_xml }

    subject { described_class.new(pbcore_xml) }

    let(:attr_names) do
      [:title, :program_title, :episode_title, :segment_title, :clip_title,
      :promo_title, :raw_footage_title, :episode_number, :description,
      :program_description, :episode_description, :segment_description,
      :clip_description, :promo_description, :raw_footage_description,
      :audience_level, :audience_rating, :asset_types, :genre,
      :spatial_coverage, :temporal_coverage, :annotation, :rights_summary,
      :rights_link, :local_identifier, :pbs_nola_code, :eidr_id, :topics,
      :subject]
    end

    let(:attrs_with_xpath_shortcuts) { attr_names - [:title, :description, :spatial_coverage, :temporal_coverage] }

    it 'maps all attributes from PBCore XML' do
      attrs = subject.asset_attributes
      # For each attribute in attr_names, make sure it has a that comes from
      # the PBCore XML factory.
      attr_names.each do |attr|
        expect(attrs[attr]).not_to be_empty
      end
    end

    it 'maps PBCore XML values to the correct attributes for AssetActor' do
      attrs = subject.asset_attributes

      # For each attribute that has an xpath shortcut helper
      attrs_with_xpath_shortcuts.each do |attr|
        expect(attrs[attr]).to eq pbcore_values_from_xpath(pbcore_xml, attr)
      end

      # Check :title and :description separately with specific helpers.
      expect(attrs[:title]).to        eq pbcore_xpath_helper(pbcore_xml).titles_without_type
      expect(attrs[:description]).to  eq pbcore_xpath_helper(pbcore_xml).descriptions_without_type
    end
  end

  describe '#physical_instantiation_attributes' do
    let(:pbcore_instantiation) { FactoryBot.build(:pbcore_instantiation_document) }
    let(:mapper) { described_class.new(pbcore_instantiation.to_xml) }
    it 'maps the attributes correctly' do
      expect { mapper.physical_instantiation_attributes }.to_not raise_error
    end
  end
end
