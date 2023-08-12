require 'rails_helper'

RSpec.describe AssetIndexer do
  subject(:solr_document) { service.generate_solr_document }
  let(:service) { described_class.new(work) }

  let(:admin_data) { create(:admin_data) }
  let(:admin_data_no_sony_ci_id) { create(:admin_data, :empty)}
  let(:admin_data_with_annotation) { create(:admin_data, :with_annotation)}

  let(:work) { build(:asset, with_admin_data: admin_data.gid, date:["2010"], broadcast_date:['2011-05'], copyright_date:['2011-05'], created_date:['2011-05-11'], ) }
  let(:work_no_sony_ci_id) { build(:asset_no_sonyci_id, with_admin_data: admin_data_no_sony_ci_id.gid, date:["2010"], broadcast_date:['2011-05'], copyright_date:['2011-05'], created_date:['2011-05-11'], ) }

  let(:asset) { create(:asset) }
  let(:asset_no_sonyci_id) { create(:asset, with_admin_data: admin_data_no_sony_ci_id.gid) }
  let(:asset_with_annotation) { create(:asset, with_admin_data: admin_data_with_annotation.gid ) }

  let(:asset_solr_doc) { described_class.new(asset) }
  let(:asset_solr_doc_no_sony_ci_id) { described_class.new(asset_no_sonyci_id) }

  #
  let(:asset_solr_doc_with_annotations) { described_class.new(asset_with_annotation)}

  let(:digital_instantiation_work) { create(:digital_instantiation) }
  let(:aapb_moving_image_digital_instantiation_work) { create(:digital_instantiation, :aapb_moving_image) }
  let(:aapb_sound_digital_instantiation_work) { create(:digital_instantiation, :aapb_sound) }
  let(:moving_image_digital_instantiation_work) { create(:digital_instantiation, :moving_image) }
  let(:sound_digital_instantiation_work) { create(:digital_instantiation, :sound) }


  let(:physical_instantiation_work) { create(:physical_instantiation) }

  context "indexes admin data" do
    it "indexes the correct fields" do
      expect(solr_document.fetch('sonyci_id_ssim')).to eq asset.sonyci_id
    end
  end

  context "thumbnail" do
    context "an asset that has digital_instations with AAPB defined as the organization" do
      context "and 'Moving Image' defined as the media_type" do
        it "has a S3 thumbnail if it has a sony_ci_id" do
          asset.ordered_members << aapb_moving_image_digital_instantiation_work
          asset.save
          solr_doc = asset_solr_doc.generate_solr_document
          default_image = ActionController::Base.helpers.image_path("http://americanarchive.org.s3.amazonaws.com/thumbnail/#{solr_doc[:id]}.jpg")
          expect(solr_doc.fetch('thumbnail_path_ss')).to eq default_image
        end
        it "has the VIDEO_NOT_DIG.png as the thumbnail if it does not have a sony_ci_id" do
          asset_no_sonyci_id.ordered_members << aapb_moving_image_digital_instantiation_work
          asset_no_sonyci_id.save
          solr_doc = asset_solr_doc_no_sony_ci_id.generate_solr_document
          default_image = ActionController::Base.helpers.image_path("/thumbs/VIDEO_NOT_DIG.png")
          expect(solr_doc.fetch('thumbnail_path_ss')).to eq default_image
        end
      end

      context "and 'Sound' defined as the media_type" do
        it "has the AUDIO.png as the thumbnail if it has a sonyci_id" do
          asset.ordered_members << aapb_sound_digital_instantiation_work
          asset.save
          solr_doc = asset_solr_doc.generate_solr_document
          default_image = ActionController::Base.helpers.image_path("/thumbs/AUDIO.png")
          expect(solr_doc.fetch('thumbnail_path_ss')).to eq default_image
        end

        it "has the AUDIO_NOT_DIG.png as the thumbnail if it does not have a sony_ci_id" do
          asset_no_sonyci_id.ordered_members << aapb_sound_digital_instantiation_work
          asset_no_sonyci_id.save
          solr_doc = asset_solr_doc_no_sony_ci_id.generate_solr_document
          default_image = ActionController::Base.helpers.image_path("/thumbs/AUDIO_NOT_DIG.png")
          expect(solr_doc.fetch('thumbnail_path_ss')).to eq default_image
        end
      end
    end

    context "an asset that does not have any digital_instations with AAPB defined as the organization" do
      context "and 'Moving Image' defined as the media_type" do
        it "has the VIDEO_NOT_DIG.png as the thumbnail" do
          asset_no_sonyci_id.ordered_members << moving_image_digital_instantiation_work
          asset_no_sonyci_id.save
          solr_doc = asset_solr_doc_no_sony_ci_id.generate_solr_document
          default_image = ActionController::Base.helpers.image_path("/thumbs/VIDEO_NOT_DIG.png")
          expect(solr_doc.fetch('thumbnail_path_ss')).to eq default_image
        end
      end
      context "and 'Sound' defined as the media_type" do
        it "has the VIDEO_NOT_DIG.png as the thumbnail" do
          asset_no_sonyci_id.ordered_members << sound_digital_instantiation_work
          asset_no_sonyci_id.save
          solr_doc = asset_solr_doc_no_sony_ci_id.generate_solr_document
          default_image = ActionController::Base.helpers.image_path("/thumbs/AUDIO_NOT_DIG.png")
          expect(solr_doc.fetch('thumbnail_path_ss')).to eq default_image
        end
      end
    end

    context "an asset with no digital instantiations" do
      it "has work_type.png as default thumbnail when work.thumbnail_id is null" do
        expect(work.thumbnail_id).to be_nil
        work_type = solr_document.fetch('has_model_ssim').first.downcase
        default_image = ActionController::Base.helpers.image_path(work_type+'.png')
        expect(solr_document.fetch('thumbnail_path_ss')).to eq default_image
      end
    end
  end

  context "dates" do
    it "has dates as daterange when any asset date attribute is present" do
      expect(work.date).to eq(['2010'])
      expect(work.broadcast_date).to eq(['2011-05'])
      expect(work.copyright_date).to eq(['2011-05'])
      expect(work.created_date).to eq(['2011-05-11'])
      expect(solr_document.fetch('date_drsim')).to eq work.date
      expect(solr_document.fetch('broadcast_date_drsim')).to eq work.broadcast_date
      expect(solr_document.fetch('copyright_date_drsim')).to eq work.copyright_date
      expect(solr_document.fetch('created_date_drsim')).to eq work.created_date
    end

    it "does not have dates as daterange when any asset date attribute is not present" do
      work.date = []
      work.broadcast_date = []
      work.copyright_date = []
      work.created_date = []
      solr_document = service.generate_solr_document
      expect(work.date).to be_empty
      expect(work.broadcast_date).to be_empty
      expect(work.copyright_date).to be_empty
      expect(work.created_date).to be_empty
      expect(solr_document.fetch('date_drsim')).to be_empty
      expect(solr_document.fetch('broadcast_date_drsim')).to be_empty
      expect(solr_document.fetch('copyright_date_drsim')).to be_empty
      expect(solr_document.fetch('created_date_drsim')).to be_empty
    end

    it "index child attributes into parent" do
      asset.ordered_members << digital_instantiation_work
      asset.ordered_members << physical_instantiation_work
      asset.save
      solr_doc = asset_solr_doc.generate_solr_document
      expect(solr_doc.fetch('media_type_ssim')).not_to be_empty

    end
  end

  context "annotations" do
    it "indexes annotation data on asset's solr document" do
      annotation = asset_with_annotation.admin_data.annotations.first
      solr_doc = asset_solr_doc_with_annotations.generate_solr_document
      # We randomize the annotation_type, so use Solrizer on the annotation_type since it
      # gets indexed in Solr by the annotation_type.
      expect(solr_doc.fetch(solr_name(annotation.annotation_type, :symbol))).to eq([annotation.value])
    end
  end
end
