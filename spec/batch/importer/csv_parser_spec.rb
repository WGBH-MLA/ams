
require 'rails_helper'
require 'importer'

RSpec.describe Importer::CSVParser do
  let(:parser) { described_class.new(File.read(file)) }
  let(:attributes) { parser.attributes }
  let(:depositor) { 'depositor@example.edu' }
  let(:file) { "#{fixture_path}/csv/sample.csv" }
  let(:first_record) { parser.first }

  context 'Importing just images' do
    # rubocop:disable RSpec/ExampleLength
    it 'parses a record' do
      expect(parser.email).to eq(depositor)
      # Title must be singular
      expect(first_record[:pbcore_path]).to eq 'spec/fixtures/sample_pbcore.xml'
      expect(first_record[:admin_set_id]).to eq 'admin_set/default'
      # expect(first_record[:file]).to contain_exactly('files/coffee.jpg', 'files/nul.jpg')
      # expect(first_record[:date_created]).to contain_exactly('2009-12')
      # expect(first_record[:contributor]).to contain_exactly(
      #   an_instance_of(RDF::URI),
      #   an_instance_of(RDF::URI)
      # )
      # expect(first_record.keys).to contain_exactly(:accession_number, :type, :title, :description,
      #                                              :subject, :resource_type, :contributor, :creator, :style_period,
      #                                              :date_created, :file, :collection, :admin_set_id, :subject_topical,
      #                                              :preservation_level, :rights_statement, :status)
    end
    # rubocop:enable RSpec/ExampleLength
  end

  describe 'validating CSV headers' do
    subject(:parsed_headers) { parser.send(:validate_headers, headers) }

    context 'with valid headers' do
      let(:headers) { %w[id accession_number pbcore_path admin_set_id] }

      it 'contains the correct headers' do
        expect(parsed_headers).to eq headers
      end
    end

    context 'with invalid headers' do
      let(:headers) { ['something bad', 'title'] }

      it 'raises an error' do
        expect { parsed_headers }.to raise_error(Importer::CSVParser::ParserError)
      end
    end

    context 'with nil headers' do
      let(:headers) { %w[id accession_number pbcore_path admin_set_id] + [nil] }

      it { is_expected.to eq headers }
    end
  end
end
