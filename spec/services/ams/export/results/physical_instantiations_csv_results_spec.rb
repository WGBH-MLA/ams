require 'rails_helper'

RSpec.describe AMS::Export::Results::PhysicalInstantiationsCSVResults do
  describe '#filepath' do
    let(:assets) do
      Array.new(rand(1..3)) do
        create(:asset,
          ordered_members: Array.new(rand(1..3)) do
            create(:physical_instantiation)
          end
        )
      end
    end

    let(:solr_docs) do
      assets.map { |asset| asset.physical_instantiations }.flatten
    end

    subject { described_class.new(solr_documents: solr_docs) }

    let(:expected_header) { AMS::CsvExportExtension.fields_for('physical_instantiation') }
    let(:expected_rows) { solr_docs.map { |solr_doc| solr_doc.csv_row_for('physical_instantiation') } }

    it 'points to a file containing Asset CSV Results' do
      csv_rows = CSV.parse(File.read(subject.filepath))
      expect(expected_header).to eq csv_rows.first
      expect(expected_rows).to eq csv_rows.slice(1..-1)
    end
  end
end
