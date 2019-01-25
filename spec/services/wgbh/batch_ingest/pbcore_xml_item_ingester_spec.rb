require 'rails_helper'
require 'hyrax/batch_ingest/spec/shared_specs'
require 'wgbh/batch_ingest/pbcore_xml_item_ingester'

RSpec.describe WGBH::BatchIngest::PBCoreXMLItemIngester do
  let(:ingester_class) { described_class }
  let(:submitter) { create(:user) }
  let(:batch) { build(:batch, submitter_email: submitter.email) }
  let(:sample_source_location) { File.join(fixture_path, 'batch_ingest', 'sample_pbcore2_xml', 'cpb-aacip_600-g73707wt6r.xml' ) }
  let(:batch_item) { build(:batch_item, batch: batch, source_location: sample_source_location)}

  it_behaves_like "a Hyrax::BatchIngest::BatchItemIngester"

  context 'given an Asset with Contribution data' do
    subject { described_class.new(batch_item) }
    let(:aapb_identifier) { build(:pbcore_identifier, :aapb) }
    let(:contributors) { build_list(:pbcore_contributor, 5) }
    let(:pbcore_description_document) { build(:pbcore_description_document,
                                              identifiers: [ aapb_identifier ],
                                              contributors: contributors ) }
    let(:pbcore_xml) { pbcore_description_document.to_xml }
    let(:batch_item) { build(:batch_item, batch: batch, source_location: nil, source_data: pbcore_xml)}

    before do
      @asset = subject.ingest
    end

    it 'ingests the Asset and the Contributions' do
      contributions = @asset.members.select { |member| member.is_a? Contribution }
      expect(contributions.count).to eq 5
    end
  end
end
