require 'rails_helper'
require 'zip'
require 'hyrax/batch_ingest/spec/shared_specs'

RSpec.describe WGBH::BatchIngest::ZippedPBCoreReader do
  let(:reader_class) { described_class }
  let (:source_location) { File.join(fixture_path, "sample_pbcore2_xml.zip") }
  let (:invalid_source_location) { File.join(fixture_path, "sample_instantiation_valid.xml") }
  # Call the shared specs
  it_behaves_like 'a Hyrax::BatchIngest::BatchReader'

  describe "perform_read" do
    let(:xml_file_name) { Zip::File.open(source_location).glob('*.xml').first.name }

    context "when source location is valid" do
      subject { described_class.new(source_location) }

      it "extracts xml files into directory" do
        subject.read
        File.directory?(subject.extraction_path).should be true
        expect(File).to exist("#{subject.extraction_path}/#{xml_file_name}")
      end

      it "creates batch items" do
        subject.read
        expect(subject.batch_items.size).to eq(1)
        expect(subject.batch_items.first.id_within_batch).to eq(File.basename(xml_file_name,".*"))
      end

    end

    context "when source location zip does not contain any xml" do
      let (:empty_zip_source) { File.join(fixture_path, "empty_zip.zip") }
      subject { described_class.new(empty_zip_source) }

      it "raises error" do
        expect { subject.read }.to raise_error(Hyrax::BatchIngest::ReaderError)
      end
    end

    context "when source location is not a valid zip file" do
      subject { described_class.new(invalid_source_location) }

      it "raises error" do
        expect { subject.read }.to raise_error(Hyrax::BatchIngest::ReaderError)
      end
    end

  end
end
