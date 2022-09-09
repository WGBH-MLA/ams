# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PbcoreXmlParser do
  describe '#create_works' do
    subject(:xml_parser) { described_class.new(importer) }
    let(:importer) { FactoryBot.create(:bulkrax_importer_pbcore_xml) }
    let(:entry) { FactoryBot.create(:bulkrax_entry, importerexporter: importer) }

    before do
      Bulkrax.field_mappings['PbcoreXmlParser'] = {
        'bulkrax_identifier' => { from: ['pbcoreIdentifier'], source_identifier: true }
      }
      allow(Bulkrax::PbcoreXmlEntry).to receive_message_chain(:where, :first_or_create!).and_return(entry)
      allow(entry).to receive(:id)
      allow(Bulkrax::ImportWorkJob).to receive(:perform_later)
    end

    context 'with good data' do
      before do
        importer.parser_fields = {
          'import_file_path' => './spec/fixtures/bulkrax/xml/pbcore_doc.xml',
          'record_element' => 'pbcoreDescriptionDocument'
        }
      end

      context 'and import_type set to single' do
        before do
          importer.parser_fields.merge!('import_type' => 'single')
        end

        it 'processes the line' do
          expect(xml_parser).to receive(:increment_counters).once
          xml_parser.create_works
        end

        it 'counts the correct number of works and collections' do
          expect(xml_parser.total).to eq(1)
          expect(xml_parser.collections_total).to eq(0)
        end
      end
    end
  end
end