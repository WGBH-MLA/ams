require 'rails_helper'
require 'pbcore'
require 'ams/cleaner/pbcore_cleaner'

RSpec.describe AMS::Cleaner::PBCoreCleaner do

  subject { described_class.new(pbcore) }
  let(:pbcore) { create(:pbcore_description_document, :full_aapb) }
  let(:fake_pipeline) { instance_double(AMS::Cleaner::Pipeline) }

  before do
    allow(fake_pipeline).to receive(:process).and_return(pbcore)
  end

  context 'with a pbcore document' do
    describe '.clean!' do

      it 'initiates an AMS::Cleaner::Pipeline and calls process' do
        expect(AMS::Cleaner::Pipeline).to receive(:new).and_return(fake_pipeline)
        expect(fake_pipeline).to receive(:process).with(pbcore)
        subject.clean!
      end

    end
  end
end