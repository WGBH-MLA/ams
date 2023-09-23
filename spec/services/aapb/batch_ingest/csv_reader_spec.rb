require 'rails_helper'

RSpec.describe AAPB::BatchIngest::CSVReader do
  let(:reader_options) { Hyrax::BatchIngest.config.ingest_types[ingest_type].reader_options }
  subject { described_class.new(csv.path, reader_options) }

  context 'for ingest type aapb_csv_reader_1' do
    let(:ingest_type) { :aapb_csv_reader_1 }

    describe '#batch_items' do
      let(:batch_items) { subject.batch_items }

      context 'when input CSV contains rows with emtpy cells for Contributor' do

        let(:csv) {
          create( :csv,
                  headers: ["Contribution", "Contribution.contributor" , "Contribution.contributor_role" , "Contribution.contributor" , "Contribution.contributor_role"],
                  rows: [
                    ["", "Patti Smith", "Everything", "Art Vandelay", "Exporter"],
                    ["", "Steve", "Key grip", "", ""],
                    ["", "", "", "", ""]
                  ]
          )
        }

        let(:contribution_data) { subject.batch_items.map { |batch_item|
          JSON.parse(batch_item.source_data)['Contribution']
        }}

        it 'does not contain data for empty Contributions' do
          skip 'TODO fix batch ingest'
          expect(contribution_data[0]).to eq( [ { "contributor" => [ "Patti Smith", "Art Vandelay"], "contributor_role"=>"Exporter" } ] )
          expect(contribution_data[1]).to eq( [ { "contributor" => [ "Steve" ], "contributor_role" => "Key grip" } ] )
          expect(contribution_data[2]).to eq( [ { "contributor" => [] } ] )
        end
      end
    end
  end
end
