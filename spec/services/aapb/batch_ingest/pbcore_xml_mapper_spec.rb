require 'rails_helper'
require 'aapb/batch_ingest/pbcore_xml_mapper'

RSpec.describe AAPB::BatchIngest::PBCoreXMLMapper, :pbcore_xpath_helper do
  describe '#asset_attributes' do
    let(:pbcore_xml) { build(:pbcore_description_document, :full_aapb).to_xml }

    subject { described_class.new(pbcore_xml) }

    let(:attr_names) do
      [:id, :title, :program_title, :episode_title, :segment_title, :clip_title,
      :promo_title, :raw_footage_title, :episode_number, :description,
      :program_description, :episode_description, :segment_description,
      :clip_description, :promo_description, :raw_footage_description,
      :audience_level, :audience_rating, :asset_types, :genre,
      :spatial_coverage, :temporal_coverage, :rights_summary,
      :rights_link, :local_identifier, :pbs_nola_code, :eidr_id, :topics,
      :date, :broadcast_date, :copyright_date, :created_date, :subject]
    end

    let(:attrs_with_xpath_shortcuts) { attr_names - [:title, :description, :date, :spatial_coverage, :temporal_coverage, :id, :holding_organization, :annotation] }
    let(:attrs) { subject.asset_attributes }

    let(:pbcore_annotation_types) { attrs[:annotations].map{ |anno| anno["annotation_type"] } }

    it 'maps all attributes from PBCore XML' do
      # For each attribute in attr_names, make sure it has a that comes from
      # the PBCore XML factory.
      attr_names.each do |attr|
        expect(attrs[attr]).not_to be_empty
      end
    end

    it 'maps PBCore XML values to the correct attributes for AssetActor' do
      # For each attribute that has an xpath shortcut helper
      attrs_with_xpath_shortcuts.each do |attr|
        expect(attrs[attr]).to eq pbcore_values_from_xpath(pbcore_xml, attr)
      end

      # Check :title, :description, :id separately with specific helpers.
      expect(attrs[:title]).to        eq pbcore_xpath_helper(pbcore_xml).titles_without_type
      expect(attrs[:description]).to  eq pbcore_xpath_helper(pbcore_xml).descriptions_without_type
      expect(attrs[:date]).to         eq pbcore_xpath_helper(pbcore_xml).dates_without_type
      expect(attrs[:id]).to           eq pbcore_xpath_helper(pbcore_xml).ams_id
    end

    it 'maps Contribution data from PBCore XML' do
      expect(attrs[:contributors]).to eq pbcore_xpath_helper(pbcore_xml).contributors_attrs
    end

    it 'correctly maps admin data' do
      expect(attrs).to have_key :sonyci_id
      expect(attrs[:sonyci_id]).not_to be_nil
    end

    it 'correctly maps annotation data' do
      expect(attrs).to have_key :annotations
      expect(attrs[:annotations].length).to eq (11)

      # Every Annotation in the attrs should have a value from the PBCore
      attrs[:annotations].each do |anno|
        expect(pbcore_values_from_xpath(pbcore_xml, anno["annotation_type"].to_sym)).to include(anno["value"])
      end
      # Every Annotation in the attrs should have a type registered with the AnnotationTypesService
      pbcore_annotation_types.each do |type|
        expect(AnnotationTypesService.new.select_all_options.to_h.values).to include(type)
      end
    end

    context 'when dates are of a known invalid type' do
      let(:pbcore_xml) do
        build(
          :pbcore_description_document,
          asset_dates: [
            build(:pbcore_asset_date, value: '0000-00-00'),
            build(:pbcore_asset_date, value: '2001-00-00'),
            build(:pbcore_asset_date, value: '2002-02-00'),
            build(:pbcore_asset_date, value: '2003-03-03')
          ]
        ).to_xml
      end

      it 'converts known invalid types to valid types' do
        expect(attrs[:date]).to eq ['2001', '2002-02', '2003-03-03']
      end
    end
  end

  describe '#physical_instantiation_attributes' do
    let(:pbcore_instantiation_xml) { build(:pbcore_instantiation_document).to_xml }
    subject { described_class.new(pbcore_instantiation_xml) }

    let(:attr_names) { multi_value_attr_names + single_value_attr_names }

    let(:multi_value_attr_names) do
      [ :dimensions, :generations, :time_start, :rights_summary,
        :rights_link ]
    end

    let(:single_value_attr_names) do
      [ :standard, :format, :location, :media_type, :duration, :colors, :tracks,
        :channel_configuration, :alternative_modes, :digitization_date, :holding_organization ]
    end

    it 'maps all attributes from PBCore XML' do
      attrs = subject.physical_instantiation_attributes
      # For each attribute in attr_names, make sure it has a value that comes from
      # the PBCore XML factory.
      attr_names.each do |attr|
        expect(attrs[attr]).not_to be_empty
      end
    end

    it 'maps the correct PBCore XML values to the physical_instantiation_attributes' do
      attrs = subject.physical_instantiation_attributes

      # For each attribute in attr_names, make sure it has the correct value
      # from the PBCore XML.
      multi_value_attr_names.each do |attr|
        # For rights_link and rights_summary, the xpath shortcut has
        # "instantiation_" prepended to it to distinguish from rights_summary
        # and rights_link for pbcore description documents.
        if [:rights_summary, :rights_link].include? attr
          xpath_shortcut = "instantiation_#{attr}".to_sym
        else
          xpath_shortcut ||= attr
        end
        expect(attrs[attr]).to eq pbcore_values_from_xpath(pbcore_instantiation_xml, xpath_shortcut)
      end

      # Uses .first to pull first value from the xpath helper
      single_value_attr_names.each do |attr|
        expect(attrs[attr]).to eq pbcore_values_from_xpath(pbcore_instantiation_xml, attr).first
      end

      # Check date and local_instantiation_identifier seperately with specific helper
      expect(attrs[:date]).to eq pbcore_xpath_helper(pbcore_instantiation_xml).dates_without_digitized_date_type
      expect(attrs[:local_instantiation_identifier]).to eq pbcore_xpath_helper(pbcore_instantiation_xml).local_instantiation_identifiers_without_ams_id
    end
  end

  describe '#essence_track_attributes' do

    let(:pbcore_xml) { FactoryBot.build(:pbcore_instantiation_essence_track).to_xml }
    let(:essence_track_attributes) { AAPB::BatchIngest::PBCoreXMLMapper.new(pbcore_xml).essence_track_attributes }
    it "maps all attributes from Essence Track XML" do

      # first for single-value fields
      expect(essence_track_attributes[:track_type]).to eq pbcore_values_from_xpath(pbcore_xml, :ess_track_type).first
      expect(essence_track_attributes[:track_id]).to eq pbcore_values_from_xpath(pbcore_xml, :ess_track_id)
      expect(essence_track_attributes[:standard]).to eq pbcore_values_from_xpath(pbcore_xml, :ess_standard).first
      expect(essence_track_attributes[:encoding]).to eq pbcore_values_from_xpath(pbcore_xml, :ess_encoding).first
      expect(essence_track_attributes[:data_rate]).to eq pbcore_values_from_xpath(pbcore_xml, :ess_data_rate).first
      expect(essence_track_attributes[:frame_rate]).to eq pbcore_values_from_xpath(pbcore_xml, :ess_frame_rate).first
      # expect(essence_track_attributes[:playback_speed]).to eq pbcore_values_from_xpath(pbcore_xml, :ess_playback_speed).first
      # expect(essence_track_attributes[:playback_speed_units_of_measure]).to eq pbcore_values_from_xpath(pbcore_xml, :ess_playback_speed_units_of_measure).first
      expect(essence_track_attributes[:sample_rate]).to eq pbcore_values_from_xpath(pbcore_xml, :ess_sample_rate).first
      expect(essence_track_attributes[:bit_depth]).to eq pbcore_values_from_xpath(pbcore_xml, :ess_bit_depth).first

      expect(essence_track_attributes[:frame_width]).to eq pbcore_xpath_helper(pbcore_xml).frame_width
      expect(essence_track_attributes[:frame_height]).to eq pbcore_xpath_helper(pbcore_xml).frame_height
      expect(essence_track_attributes[:aspect_ratio]).to eq pbcore_values_from_xpath(pbcore_xml, :ess_aspect_ratio).first
      expect(essence_track_attributes[:time_start]).to eq pbcore_values_from_xpath(pbcore_xml, :ess_time_start).first
      expect(essence_track_attributes[:duration]).to eq pbcore_values_from_xpath(pbcore_xml, :ess_duration).first
      expect(essence_track_attributes[:annotation]).to eq pbcore_values_from_xpath(pbcore_xml, :ess_annotations)
    end
  end
end
