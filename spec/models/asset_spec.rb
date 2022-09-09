# Generated via
#  `rails generate hyrax:work Asset`
require 'rails_helper'

RSpec.describe Asset do
  let(:asset) { build(:asset) }

  context 'properties' do
    subject { build :asset }

    it { is_expected.to have_property(:bulkrax_identifier).with_predicate("http://ams2.wgbh-mla.org/resource#bulkraxIdentifier") }
    it { is_expected.to have_property(:title).with_predicate(::RDF::Vocab::DC.title) }
    it { is_expected.to have_property(:asset_types).with_predicate(::RDF::Vocab::EBUCore.hasType) }
    it { is_expected.to have_property(:genre).with_predicate(::RDF::Vocab::EBUCore.hasGenre) }
    it { is_expected.to have_property(:date).with_predicate(::RDF::Vocab::DC.date) }
    it { is_expected.to have_property(:broadcast_date).with_predicate('http://pbcore.org#hasBroadcastDate') }
    it { is_expected.to have_property(:created_date).with_predicate('http://pbcore.org#hasCreatedDate') }
    it { is_expected.to have_property(:copyright_date).with_predicate('http://pbcore.org#hasCopyrightDate') }
    it { is_expected.to have_property(:episode_number).with_predicate(::RDF::Vocab::EBUCore.episodeNumber) }
    it { is_expected.to have_property(:spatial_coverage).with_predicate(::RDF::Vocab::DC.coverage) }
    it { is_expected.to have_property(:temporal_coverage).with_predicate('http://id.loc.gov/ontologies/bibframe.html#p_temporalCoverage') }
    it { is_expected.to have_property(:audience_level).with_predicate(::RDF::Vocab::EBUCore.hasTargetAudience) }
    it { is_expected.to have_property(:audience_rating).with_predicate('https://www.ebu.ch/metadata/ontologies/ebucore/index.html#Type') }
    it { is_expected.to have_property(:annotation).with_predicate(::RDF::Vocab::SKOS.note) }
    it { is_expected.to have_property(:rights_summary).with_predicate(::RDF::Vocab::DC11.rights) }
    it { is_expected.to have_property(:rights_link).with_predicate('http://www.europeana.eu/rights') }
    it { is_expected.to have_property(:local_identifier).with_predicate('http://id.loc.gov/vocabulary/identifiers/local') }
    it { is_expected.to have_property(:pbs_nola_code).with_predicate(::RDF::Vocab::EBUCore.hasIdentifier) }
    it { is_expected.to have_property(:eidr_id).with_predicate('https://www.w3.org/2002/07/owl#sameAs') }
    it { is_expected.to have_property(:topics).with_predicate(::RDF::Vocab::EBUCore.hasKeyword) }
    it { is_expected.to have_property(:subject).with_predicate(::RDF::Vocab::DC11.subject) }
    it { is_expected.to have_property(:program_title).with_predicate('http://pbcore.org#hasProgramTitle') }
    it { is_expected.to have_property(:episode_title).with_predicate('http://pbcore.org#hasEpisodeTitle') }
    it { is_expected.to have_property(:segment_title).with_predicate('http://pbcore.org#hasSegmentTitle') }
    it { is_expected.to have_property(:raw_footage_title).with_predicate('http://pbcore.org#hasRawFootageTitle') }
    it { is_expected.to have_property(:promo_title).with_predicate('http://pbcore.org#hasPromoTitle') }
    it { is_expected.to have_property(:clip_title).with_predicate('http://pbcore.org#hasClipTitle') }
    it { is_expected.to have_property(:program_description).with_predicate('http://pbcore.org#hasProgramDescription') }
    it { is_expected.to have_property(:episode_description).with_predicate('http://pbcore.org#hasEpisodeDescription') }
    it { is_expected.to have_property(:segment_description).with_predicate('http://pbcore.org#hasSegmentDescription') }
    it { is_expected.to have_property(:raw_footage_description).with_predicate('http://pbcore.org#hasRawFootageDescription') }
    it { is_expected.to have_property(:promo_description).with_predicate('http://pbcore.org#hasPromoDescription') }
    it { is_expected.to have_property(:clip_description).with_predicate('http://pbcore.org#hasClipDescription') }
    it { is_expected.to have_property(:producing_organization).with_predicate(::RDF::Vocab::DC11.creator) }
  end

  context "with AdminData" do
    let(:admin_data) { FactoryBot.create(:admin_data) }
    let(:annotation) { FactoryBot.create(:annotation, admin_data_id: admin_data.id)}
    let(:asset) { FactoryBot.build(:asset, with_admin_data: admin_data.gid) }

    describe ".admin_data_gid" do
      it 'returns the expected AdminData' do
        expect(asset).to have_property(:admin_data_gid).with_predicate(/pbcore.org#hasAAPBAdminData/)
        expect(asset.admin_data_gid).to eq(admin_data.gid)
      end

      it "returns ActiveRecord::RecordNotFound if cannot find admin_data for the gid" do
        gid = 'gid://ams/admindata/999'
        expect { asset.admin_data_gid = gid }.to raise_error(ActiveRecord::RecordNotFound, "Couldn't find AdminData matching GID #{gid}")
      end
    end

    describe ".find_admin_data_attribute" do
      it 'returns the expected value' do
        expect(asset.find_admin_data_attribute("sonyci_id")).to eq(admin_data.sonyci_id)
      end
    end

    describe '.find_annotation_attribute' do
      it 'returns the expected value' do
        expect(asset.find_annotation_attribute(annotation.annotation_type)).to eq([annotation.value])
      end
    end
  end

  context "date format validation" do
    let(:asset) { FactoryBot.build(:asset) }
    it "is valid with year only as date format" do
      asset.date = ['2001']
      asset.broadcast_date = ['2002']
      asset.copyright_date = ['2003']
      asset.created_date = ['2004']
      expect(asset.date).to eq(['2001'])
      expect(asset.broadcast_date).to eq(['2002'])
      expect(asset.copyright_date).to eq(['2003'])
      expect(asset.created_date).to eq(['2004'])
      expect(asset.valid?).to be true
    end

    it "is valid with year-month only as date format" do
      asset.date = ['2001-01']
      asset.broadcast_date = ['2002-02']
      asset.copyright_date = ['2003-03']
      asset.created_date = ['2004-04']
      expect(asset.date).to eq(['2001-01'])
      expect(asset.broadcast_date).to eq(['2002-02'])
      expect(asset.copyright_date).to eq(['2003-03'])
      expect(asset.created_date).to eq(['2004-04'])
      expect(asset.valid?).to be true
    end

    it "is valid with year-month-day  as date format" do
      asset.date = ['2001-01-10']
      asset.broadcast_date = ['2002-02-11']
      asset.copyright_date = ['2003-03-12']
      asset.created_date = ['2004-04-13']
      expect(asset.date).to eq(['2001-01-10'])
      expect(asset.broadcast_date).to eq(['2002-02-11'])
      expect(asset.copyright_date).to eq(['2003-03-12'])
      expect(asset.created_date).to eq(['2004-04-13'])
      expect(asset.valid?).to be true
    end

    it "is invalid with incorrect date format" do
      asset.date = ['2001/01/10']
      asset.broadcast_date = ['2002/02/11']
      asset.copyright_date = ['2003/03/12']
      asset.created_date = ['2004/04/13']
      expect(asset.date).to eq(['2001/01/10'])
      expect(asset.broadcast_date).to eq(['2002/02/11'])
      expect(asset.copyright_date).to eq(['2003/03/12'])
      expect(asset.created_date).to eq(['2004/04/13'])
      expect(asset.valid?).to be false
    end
  end

  describe '#destroy' do
    before do
      @ordered_members = [
        create_list(:digital_instantiation, rand(1..3)),
        create_list(:physical_instantiation, rand(1..3)),
        create(:contribution)
      ].flatten

      @asset = create(
        :asset,
        ordered_members: @ordered_members
      )

      # get the AdminData record to verify its destruction
      @admin_data = @asset.admin_data

      # Run the method under test, and assert expectations in the examples.
      @asset.destroy!
    end

    it 'destroys child PhysicalInstantiations, DigitalInstantiations, and associated AdminData' do
      @ordered_members.each do |child|
        expect { child.reload }.to raise_error ActiveFedora::ObjectNotFoundError
      end

      expect { @admin_data.reload }.to raise_error ActiveRecord::RecordNotFound
    end
  end
end
