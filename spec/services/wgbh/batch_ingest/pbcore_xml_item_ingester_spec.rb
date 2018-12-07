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

  describe '#ingest' do
    subject { ingester_class.new(batch_item) }
    let(:fake_actor) { instance_double(Hyrax::Actors::AssetActor) }
    let(:fake_actor_env) { instance_double(Hyrax::Actors::Environment) }

    before do
      # Set up the spy on Hyrax::Actors::AssetActor#create
      allow(fake_actor).to receive(:create).with(fake_actor_env)

      # TODO: Is there a better pattern to use here, rather than mocking the
      # return value of private methods?
      allow(subject).to receive(:actor).and_return(fake_actor)
      allow(subject).to receive(:actor_env).and_return(fake_actor_env)

      # Call the method that triggers the expected side effects.
      subject.ingest
    end


    it 'calls #create on the AssetActor with the proper environment' do
      expect(fake_actor).to have_received(:create).with(fake_actor_env).exactly(1).times
    end
  end
end
