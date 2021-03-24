require 'rails_helper'

RSpec.describe AMS::Export::Results::AssetsCSVResults do
  describe '#filepath' do
    let(:assets) { create_list(:asset, rand(2..4)) }
    let(:solr_docs) { assets.map { |asset| SolrDocument.new(asset.to_solr) } }
    let(:expected_header) { AMS::CsvExportExtension.fields_for('asset') }
    let(:expected_rows) { solr_docs.map { |solr_doc| solr_doc.csv_row_for('asset') } }

    let(:subject) { described_class.new(solr_documents: solr_docs) }

    it 'points to a file containing Asset CSV Results' do
      csv_rows = CSV.parse(File.read(subject.filepath))
      expect(expected_header).to eq csv_rows.first
      expect(expected_rows).to eq csv_rows.slice(1..-1)
    end
  end
end
