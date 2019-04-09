require 'rails_helper'
require 'aapb/batch_ingest/zipped_pbcore_digital_instantiation_mapper'

RSpec.describe AAPB::BatchIngest::ZippedPBCoreDigitalInstantiationMapper, :pbcore_xpath_helper do

  describe '#digital_instantiation_attributes' do
    let(:user) { create(:aapb_admin_user) }
    let(:pbcore_xml) { create(:pbcore_instantiation_document, :media_info).to_xml }
    let(:batch_item) { build(:batch_item, batch: build(:batch, submitter_email: user.email), id_within_batch: "sample_digital_instantiation.xml", source_location: File.join(fixture_path, "batch_ingest", "sample_pbcore_digital_instantiation", "digital_instantiation_manifest.xlsx"), source_data: pbcore_xml) }
    let(:attr_names) do
      [ :date, :digitization_date, :dimensions, :standard, :location, :media_type, :format, :time_start, :duration, :colors, :rights_summary, :rights_link, :local_instantiation_identifier, :tracks, :channel_configuration, :alternative_modes, :format ]
    end

    let(:attrs) { subject.digital_instantiation_attributes }

    context "when batch_item is valid" do
      subject { described_class.new(batch_item) }

      it 'maps attributes from PBCore XML and Manifest' do
        # For each attribute in attr_names, make sure it has a that comes from
        # the PBCore XML factory.
        attr_names.each do |attr|
          expect(attrs[attr]).not_to be_empty
        end
        expect(attrs[:generations]).to eq(["Proxy", "Master"])
        expect(attrs[:location]).to eq("American Archive of Public Broadcasting")
        expect(attrs[:aapb_preservation_lto]).to eq("fhqwhgads")
        expect(attrs[:aapb_preservation_disk]).to eq("disky mc diskface")
      end
    end
  end
end
