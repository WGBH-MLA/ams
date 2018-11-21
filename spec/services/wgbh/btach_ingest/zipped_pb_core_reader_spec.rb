require 'rails_helper'
require 'zip'

RSpec.describe WGBH::BatchIngest::ZippedPBCoreReader do
  describe "perform_read" do
    subject { WGBH::BatchIngest::ZippedPBCoreReader.new(valid_source) }

    let (:valid_source) {Rails.root.join("spec","fixtures", "sample_pbcore2_xml.zip")}
    let (:invalid_source) {Rails.root.join("spec","fixtures", "sample_instantiation_valid.xml")}
    let (:empty_zip_source) {Rails.root.join("spec","fixtures", "empty_zip.zip")}
    let(:xml_file_name) {Zip::File.open(valid_source).glob('*.xml').first.name}



    context "when source location is valid" do
      subject { WGBH::BatchIngest::ZippedPBCoreReader.new(valid_source) }

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
      subject { WGBH::BatchIngest::ZippedPBCoreReader.new(empty_zip_source) }
      it "raises error" do
        expect { subject.read }.to raise_error(Hyrax::BatchIngest::ReaderError)
      end
    end

    context "when source location is not a valid zip file" do
      subject { WGBH::BatchIngest::ZippedPBCoreReader.new(invalid_source) }

      it "raises error" do
        expect { subject.read }.to raise_error(Hyrax::BatchIngest::ReaderError)
      end
    end

  end
end