# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CsvParser do
  describe '#create_works' do
    subject { described_class.new(importer) }
    let(:importer) { FactoryBot.create(:bulkrax_importer_csv) }
    let(:entry) { FactoryBot.create(:bulkrax_entry, importerexporter: importer) }

    before do
      allow(Bulkrax::CsvEntry).to receive_message_chain(:where, :first_or_create!).and_return(entry)
      allow(entry).to receive(:id)
      allow(Bulkrax::ImportWorkJob).to receive(:perform_later)
    end

    context 'with malformed CSV' do
      before do
        importer.parser_fields = { import_file_path: './spec/fixtures/csv/malformed.csv' }
      end

      it 'returns an empty array, and records the error on the importer' do
        subject.create_works
        expect(importer.last_error['error_class']).to eq('CSV::MalformedCSVError')
      end
    end

    context 'without an identifier column' do
      before do
        importer.parser_fields = { import_file_path: './spec/fixtures/csv/bad.csv' }
      end

      it 'skips all of the lines' do
        expect(subject.importerexporter).not_to receive(:increment_counters)
        subject.create_works
      end
    end

    context 'with a nil value in the identifier column' do
      before do
        importer.parser_fields = { import_file_path: './spec/fixtures/csv/ok.csv' }
      end

      it 'skips the bad line' do
        expect(subject).to receive(:increment_counters).twice
        subject.create_works
      end

      context 'with fill_in_blank_source_identifiers set' do
        it 'fills in the source_identifier if fill_in_blank_source_identifiers is set' do
          expect(subject).to receive(:increment_counters).twice
          expect(Bulkrax).to receive(:fill_in_blank_source_identifiers).exactly(4).times.and_return(->(_obj, _index) { "4649ee79-7d7a-4df0-86d6-d6865e2925ca"} )
          subject.create_works
          expect(subject.seen).to include("4649ee79-7d7a-4df0-86d6-d6865e2925ca")
        end
      end
    end

    context 'with good data' do
      before do
        importer.parser_fields = { import_file_path: './spec/fixtures/csv/good.csv' }
      end

      it 'processes the line' do
        expect(subject).to receive(:increment_counters).twice
        subject.create_works
      end

      it 'has a source id field' do
        expect(subject.source_identifier).to eq(:source_identifier)
      end

      it 'has a work id field' do
        expect(subject.work_identifier).to eq(:source)
      end

      it 'has custom source and work id fields' do
        subject.importerexporter.field_mapping['bulkrax_identifier'] = { 'from' => ['bulkrax_identifier'], 'source_identifier' => true }
        expect(subject.source_identifier).to eq(:bulkrax_identifier)
        expect(subject.work_identifier).to eq(:bulkrax_identifier)
      end

      it 'counts the correct number of works and collections' do
        subject.records
        expect(subject.total).to eq(2)
        expect(subject.collections_total).to eq(0)
      end

      context 'when parent id is present' do

      end
    end
  end

  describe '#create_bulkrax_identifier' do

  end

  describe '#add_object' do

  end

  describe 'missing_elements' do

  end

  describe '#setup_parents' do

  end
end