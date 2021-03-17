require 'rails_helper'

RSpec.describe AMS::Export::Results::PBCoreZipResults do
  describe '#filepath' do
    let(:solr_docs) do
      create_list(:asset, rand(2..4)).map { |asset| SolrDocument.new(asset.to_solr) }
    end

    let(:subject) { described_class.new(solr_documents: solr_docs) }


    it 'points to a file containing Zipped PBCore results for all the Asset records' do
      Zip::File.open(subject.filepath) do |zipfile|
        unzipped_pbcore_ids = zipfile.map do |entry|
          pbcore = PBCore::DescriptionDocument.parse(entry.get_input_stream.read)
          pbcore.identifiers.detect do |pbcore_identifier|
            pbcore_identifier.source == 'http://americanarchiveinventory.org'
          end.value
        end

        expect(Set.new(unzipped_pbcore_ids)).to eq Set.new(solr_docs.map(&:id))
      end
    end
  end
end
