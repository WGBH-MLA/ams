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
end
