require 'rails_helper'

RSpec.describe AMS::PbcoreXmlExportExtension, :pbcore_xpath_helper do

  let(:admin_data_with_annotation) { create(:admin_data, :with_special_collections_annotation) }
  let(:digital_instantiation) { create(:digital_instantiation, :aapb_moving_image) }
  let(:physical_instantiation) { create(:physical_instantiation) }

  let(:asset_1) { create(:asset, admin_data: admin_data_with_annotation, ordered_members: [ digital_instantiation ]) }
  let(:asset_2) { create(:asset, ordered_members: [ physical_instantiation ]) }

  let(:solr_document_1) { SolrDocument.find(asset_1.id) }
  let(:solr_document_2) { SolrDocument.find(asset_2.id) }


  # Using 2 different PBCore strings due to the pbcore_xpath_helper not being smart enough to
  # process different instantiations. This could be address as part of the
  # "AMS 500: Rewrite pbcore_xpath_helper to use PBCore Gem" ticket.

  let(:pbcore_1) { solr_document_1.export_as_pbcore }
  let(:pbcore_2) { solr_document_2.export_as_pbcore }

  describe ".export_as_pbcore" do
     describe "generates the expected PBCore for an Asset, DigitalInstantiation, and PhysicalInstantiation" do
      let(:asset_attrs) do
        [:id, :title, :program_title, :episode_title, :segment_title, :clip_title,
        :promo_title, :raw_footage_title, :episode_number, :series_title,
        :description, :program_description, :episode_description, :series_description,
        :segment_description, :clip_description, :promo_description,
        :raw_footage_description, :audience_level, :audience_rating, :asset_types,
        :genre, :rights_summary, :sonyci_id, :special_collections,
        :rights_link, :local_identifier, :pbs_nola_code, :eidr_id, :topics,
        :date, :broadcast_date, :copyright_date, :created_date, :subject,
        :producing_organization]
      end

      let(:asset_attrs_with_xpath_shortcuts) { asset_attrs - [:title, :description, :date, :id, :spatial_coverage, :temporal_coverage, :producing_organization, :annotation] }

      let(:digital_instantiation_attrs) do
        [:location, :generations, :media_type, :holding_organization, :digital_format]
      end

      let(:physical_instantiation_attrs) do
        [:location, :media_type, :format]
      end

      it 'maps expected the expected Asset values' do
        asset_attrs_with_xpath_shortcuts.each do |attr|
          expect(pbcore_xpath_helper(pbcore_1).values_from_xpath(attr)).to match_array(asset_1.send(attr))
        end

        # Check with specific helpers.
        expect(pbcore_xpath_helper(pbcore_1).titles_without_type).to match_array(asset_1.title)
        expect(pbcore_xpath_helper(pbcore_1).descriptions_without_type).to match_array(asset_1.description)
        expect(pbcore_xpath_helper(pbcore_1).dates_without_type).to match_array(asset_1.date)
        expect(pbcore_xpath_helper(pbcore_1).ams_id).to eq(asset_1.id)
        expect(pbcore_xpath_helper(pbcore_1).spatial_coverage).to match_array(asset_1.spatial_coverage)
        expect(pbcore_xpath_helper(pbcore_1).temporal_coverage).to match_array(asset_1.temporal_coverage)
        expect(pbcore_xpath_helper(pbcore_1).producing_organization).to match_array(asset_1.producing_organization)
        expect(pbcore_xpath_helper(pbcore_1).annotations_without_type).to match_array(asset_1.annotation)
      end

      it 'maps expected the expected DigitalInstantiation values' do
        digital_instantiation_attrs.each do |attr|
          expect(pbcore_xpath_helper(pbcore_1).values_from_xpath(attr)).to match_array(digital_instantiation.send(attr))
        end
      end

      it 'maps expected the expected PhysicalInstantiation values' do
        physical_instantiation_attrs.each do |attr|
          expect(pbcore_xpath_helper(pbcore_2).values_from_xpath(attr)).to match_array(physical_instantiation.send(attr))
        end
      end
    end
  end

end