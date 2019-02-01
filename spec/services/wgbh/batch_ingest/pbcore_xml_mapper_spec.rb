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
    let(:attrs) { subject.asset_attributes }

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

      # Check :title and :description separately with specific helpers.
      expect(attrs[:title]).to        eq pbcore_xpath_helper(pbcore_xml).titles_without_type
      expect(attrs[:description]).to  eq pbcore_xpath_helper(pbcore_xml).descriptions_without_type
    end

    it 'maps Contribution data from PBCore XML' do
      expect(attrs[:contributors]).to eq pbcore_xpath_helper(pbcore_xml).contributors_attrs
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
        :channel_configuration, :alternative_modes, :digitization_date ]
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

  describe '#physical_instantiation_attributes' do
    let(:pbcore_instantiation_xml) { build(:pbcore_instantiation_document, essence_tracks: [ build(:pbcore_instantiation_essence_track) ]).to_xml }
    subject { described_class.new(pbcore_instantiation_xml) }



    it 'maps all attributes from PBCore XML' do
      attrs = subject.essence_track_attributes


      # xpath helper!

      # For each attribute in attr_names, make sure it has a value that comes from
      # the PBCore XML factory.
      attr_names.each do |attr|
        expect(attrs[attr]).not_to be_empty
      end
    end
  end


  describe '#essence_track_attributes' do
    let(:essence_track_xml) { build(:pbcore_instantiation_essence_track).to_xml }
    subject { described_class.new(essence_track_xml) }

    let(:attr_names) do
      [:track_type,:track_id,:standard,:encoding,:data_rate,:frame_rate,:playback_inch_per_sec,:playback_frame_per_sec,:sample_rate,:bit_depth,:frame_width,:frame_height,:aspect_ratio,:time_start,:duration,:annotation]
    end


    it 'maps all attributes from PBCore XML' do
      attrs = subject.essence_track_attributes

      require('pry');binding.pry
      # xpath helper!

      # For each attribute in attr_names, make sure it has a value that comes from
      # the PBCore XML factory.
      attr_names.each do |attr|
        expect(attrs[attr]).not_to be_empty
      end
    end
  end
end
