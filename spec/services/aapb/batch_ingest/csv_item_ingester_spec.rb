require 'rails_helper'
require 'aapb/batch_ingest'

RSpec.describe AAPB::BatchIngest::CSVItemIngester do
  let(:new_source_data) { "{\"Asset\":{\"annotations\":[{\"annotation_type\":\"level_of_user_access\",\"value\":\"On Location\"},{\"annotation_type\":\"cataloging_status\",\"value\":\"Yes\"},{\"annotation_type\":\"outside_url\",\"value\":\"https://www.outsideurl.com\"},{\"annotation_type\":\"special_collections\",\"value\":\"A1\"},{\"annotation_type\":\"transcript_status\",\"value\":\"Correct\"}],\"id\":\"cpb-aacip_600-4746q1sh20\",\"sonyci_id\":[\"b91781c13b414d7f9ce610879d9c5b6e\"],\"pbs_nola_code\":[\"10\"],\"eidr_id\":[\"1wsx\"],\"asset_types\":[\"Clip\"],\"broadcast_date\":[\"2010-01-01\"],\"created_date\":[\"2010-01-01\"],\"copyright_date\":[\"2010-01-01\"],\"series_title\":[\"Series Title\"],\"episode_description\":[\"asd\"],\"genre\":[\"Debate\"],\"topics\":[\"Dance\"],\"subject\":[\"Stuff\"],\"spatial_coverage\":[\"Jupiter\"],\"audience_level\":[\"Mature\"],\"rights_summary\":[\"Summary of rights\"],\"rights_link\":[\"In Copyright\"],\"producing_organization\":[\"KLOS\"]},\"Contribution\":[{\"contributor\":[\"Patti Smith\"],\"contributor_role\":\"Everything\"}],\"PhysicalInstantiation\":[{\"format\":\"1 inch videotape\",\"media_type\":\"Moving Image\",\"location\":\"Boston\",\"aapb_preservation_disk\":\"disk1\",\"aapb_preservation_lto\":\"lto2\"}]}"
  }
  let(:physical_instantiation_data) {

  }
  let(:update_source_data) {
    "{\"Asset\":{\"id\":\"cpb-aacip_600-4746q1sh21\",\"asset_types\":[\"Album\"],\"local_identifier\":[\"wfreu5\"],\"sonyci_id\":[\"wfreu6\"],\"annotations\":[{\"annotation_type\":\"special_collections\",\"value\":\"Snowflake Collection\"}]}}"
  }
  # :preserve_source_data does not include sonyci_id, local_identifier and adds an organization
  # annotation to check that the existing data from the factories is preserved
  let(:preserve_source_data) {
    "{\"Asset\":{\"id\":\"cpb-aacip_600-4746q1sh21\",\"asset_types\":[\"Album\"],\"annotations\":[{\"annotation_type\":\"organization\",\"value\":\"Birdnote\"}]}}"
  }
  let(:multivalue_add_source_data) {
    "{\"Asset\":{\"id\":\"cpb-aacip_600-4746q1sh22\",\"sonyci_id\":[\"123456f\"],\"asset_types\":[\"Segment\"],\"genre\":[\"Interview\"],\"spatial_coverage\":[\"Mars\"],\"annotations\":[{\"annotation_type\":\"special_collections\",\"value\":\"Snowflake Collection\"}]}}"
  }
  let(:invalid_source_data) { "{\"Asset\":{\"id\":\"cpb-aacip_600-4746q1sh20\",\"sonyci_id\":[\"b91781c13b414d7f9ce610879d9c5b6e\"],\"pbs_nola_code\":[\"10\"],\"eidr_id\":[\"1wsx\"],\"asset_types\":[\"Clip\"],\"broadcast_date\":[\"2010-01-01\"],\"created_date\":[\"1/1/10\"],\"copyright_date\":[\"2010-01-01\"],\"series_title\":[\"Series Title\"],\"episode_description\":[\"asd\"],\"genre\":[\"Debate\"],\"topics\":[\"Dance\"],\"subject\":[\"Stuff\"],\"spatial_coverage\":[\"Jupiter\"],\"audience_level\":[\"Mature\"],\"rights_summary\":[\"Summary of rights\"],\"rights_link\":[\"In Copyright\"],\"producing_organization\":[\"KLOS\"]},\"Contribution\":[{\"contributor\":[\"Patti Smith\"],\"contributor_role\":\"Everything\"}],\"PhysicalInstantiation\":[{\"format\":\"1 inch videotape\",\"media_type\":\"Moving Image\",\"location\":\"Boston\",\"aapb_preservation_disk\":\"disk1\",\"aapb_preservation_lto\":\"lto2\"}]}"
  }

  let(:user) { create(:aapb_admin_user) }

  let(:new_batch) { build(:batch, ingest_type: 'aapb_csv_reader_1', submitter_email: user.email) }
  let(:new_batch_item) { build(:batch_item, batch: new_batch, source_data: new_source_data, source_location: nil, status: 'initialized') }
  let(:new_asset) { described_class.new(new_batch_item).ingest }

  let(:update_batch) { build(:batch, ingest_type: 'aapb_csv_reader_3', submitter_email: user.email) }
  let(:update_batch_item) { build(:batch_item, batch: update_batch, source_data: update_source_data, source_location: nil, status: 'initialized') }
  let(:update_asset) { described_class.new(update_batch_item).ingest }

  let(:preserve_batch) { build(:batch, ingest_type: 'aapb_csv_reader_3', submitter_email: user.email) }
  let(:preserve_batch_item) { build(:batch_item, batch: preserve_batch, source_data: preserve_source_data, source_location: nil, status: 'initialized') }
  let(:preserve_asset) { described_class.new(preserve_batch_item).ingest }

  let(:multivalue_attribute_batch) { build(:batch, ingest_type: 'aapb_csv_reader_4', submitter_email: user.email) }
  let(:multivalue_attribute_batch_item) { build(:batch_item, batch: multivalue_attribute_batch, source_data: multivalue_add_source_data, source_location: nil, status: 'initialized') }
  let(:multivalue_attribute_update_asset) { described_class.new(multivalue_attribute_batch_item).ingest }

  let(:invalid_batch) { build(:batch, ingest_type: 'aapb_csv_reader_1', submitter_email: user.email) }
  let(:invalid_batch_item) { build(:batch_item, batch: invalid_batch, source_data: invalid_source_data, source_location: nil, status: 'initialized') }
  let(:invalid_asset) { described_class.new(invalid_batch_item).ingest }


  describe '#ingest new Assets' do
    context 'using aapb_csv_reader_1' do
      it 'creates a new Asset' do
        new_asset.reload
        expect(new_asset).to be_instance_of(Asset)
        expect(new_asset.members.select { |member| member.is_a? Contribution }.length).to eq(1)
        expect(new_asset.members.select { |member| member.is_a? PhysicalInstantiation }.length).to eq(1)
        expect(new_asset.admin_data.annotations.length).to eq(5)
      end
    end
  end

  describe '#ingest new PhysicalInstantiation' do
    context 'using aapb_csv_reader_2' do
      let(:admin_data) { create(:admin_data) }
      let(:asset) { create(:asset, id: 'cpb-aacip_600-4746q1sh21', with_admin_data: admin_data.gid) }
      it 'creates and associates a new PhysicalInstantiation' do


      end
    end
  end


  describe '#ingest and overwrite Asset, AdminData, and Annotation attributes' do
    context 'using aapb_csv_reader_3' do
      let(:admin_data) { create(:admin_data, :with_special_collections_annotation) }
      let(:asset) { create(:asset, id: 'cpb-aacip_600-4746q1sh21', with_admin_data: admin_data.gid) }
      it 'updates an existing Asset' do
        expect(asset.asset_types).to eq(['Clip','Promo'])
        expect(asset.local_identifier).to eq(['WGBH-11'])
        expect(asset.sonyci_id).to eq(['Sony-1', 'Sony-2'])
        expect(asset.admin_data.annotations.map(&:value) ).to eq(['Collection1'])
        update_asset
        asset.reload
        asset.admin_data.reload
        expect(asset.asset_types).to eq(['Album'])
        expect(asset.local_identifier).to eq(['wfreu5'])
        expect(asset.sonyci_id).to eq(['wfreu6'])
        expect(asset.admin_data.annotations.map(&:value) ).to eq(['Snowflake Collection'])
      end
    end
  end

  describe '#ingest and preserve existing Asset, AdminData, and Annotation attributes' do
    context 'using aapb_csv_reader_3' do
      let(:admin_data) { create(:admin_data, :with_special_collections_annotation) }
      let(:asset) { create(:asset, id: 'cpb-aacip_600-4746q1sh21', with_admin_data: admin_data.gid) }
      it 'updates an existing Asset, AdminData, and Annotations and preserves the existing data' do
        expect(asset.asset_types).to eq(['Clip','Promo'])
        expect(asset.local_identifier).to eq(['WGBH-11'])
        expect(asset.sonyci_id).to eq(['Sony-1', 'Sony-2'])
        expect(asset.admin_data.annotations.map(&:value) ).to eq(['Collection1'])
        preserve_asset
        asset.reload
        asset.admin_data.reload
        expect(asset.asset_types).to eq(['Album'])
        expect(asset.local_identifier).to eq(['WGBH-11'])
        expect(asset.sonyci_id).to eq(['Sony-1', 'Sony-2'])
        expect(asset.admin_data.annotations.map(&:value).sort).to eq(['Birdnote','Collection1'])
      end
    end
  end

  describe '#ingest and add to Asset multivalue attributes' do
    context 'using aapb_csv_reader_4' do
      let(:admin_data) { create(:admin_data, :with_special_collections_annotation) }
      let(:asset) { create(:asset, id: 'cpb-aacip_600-4746q1sh22', with_admin_data: admin_data.gid) }
      it 'updates an existing Asset with new multivalue attributes' do
        expect(asset.asset_types).to eq(['Clip','Promo'])
        expect(asset.genre).to eq(['Drama','Debate'])
        expect(asset.spatial_coverage).to eq(['TEST spatial_coverage'])
        expect(asset.admin_data.sonyci_id).to eq(['Sony-1','Sony-2'])
        expect(asset.admin_data.annotations.map(&:value) ).to eq(['Collection1'])
        multivalue_attribute_update_asset
        asset.reload
        asset.admin_data.reload
        expect(asset.asset_types.sort).to eq(['Clip', 'Promo', 'Segment'])
        expect(asset.genre.sort).to eq(['Debate', 'Drama', 'Interview'])
        expect(asset.spatial_coverage.sort).to eq(['Mars', 'TEST spatial_coverage'])
        expect(asset.admin_data.sonyci_id).to eq(['123456f', 'Sony-1', 'Sony-2'])
        expect(asset.admin_data.annotations.map(&:value) ).to eq(['Collection1','Snowflake Collection'])
      end
    end
  end

  describe '#ingest invalid Assets' do
    context 'using aapb_csv_reader_1' do
      it 'raises a date validation error' do
        expect{ invalid_asset.reload }.to raise_error(RuntimeError, "Batch item contained invalid data.\n\n{:created_date=>[\"invalid date format: 1/1/10\"]}")
      end
    end
  end

end