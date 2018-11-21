require 'rails_helper'
require 'zip'

RSpec.describe WGBH::BatchIngest::ZippedPBCoreReader do
  describe "perform_read" do
    subject { WGBH::BatchIngest::ZippedPBCoreReader.new(valid_source) }

    let (:valid_source) {Rails.root.join("spec","fixtures", "sample_pbcore2_xml.zip")}
    let (:invalid_source) {Rails.root.join("spec","fixtures", "sample_instantiation_valid.xml")}
    let (:empty_zip_source) {Rails.root.join("spec","fixtures", "empty_zip.zip")}
    let(:xml_file_name) {Zip::File.open(valid_source){|f| f.name }}



    it "creates random extraction directory" do
      subject { WGBH::BatchIngest::ZippedPBCoreReader.new(invalid_source) }
      expect(subject.root_extraction_path).not_to be_empty
      subject.read
      File.directory?(subject.extraction_path).should be true
    end

    it "creates batch items for valid zip file with pbcore documents" do
      subject.read
      expect(subject.batch_items.size).to eq(1)
      expect(subject.batch_items.first.id_within_batch).to eq(File.basename(xml_file_name,".*"))
    end

    it "rails error when source file is not zip" do
      expect { WGBH::BatchIngest::ZippedPBCoreReader.new(invalid_source).read }.to raise_error(Hyrax::BatchIngest::ReaderError)
    end

    it "rails error when source zip file does not contains pbcore xml documents " do
      expect { WGBH::BatchIngest::ZippedPBCoreReader.new(empty_zip_source).read }.to raise_error(Hyrax::BatchIngest::ReaderError)
    end

  end
end