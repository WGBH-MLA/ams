# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PbcoreManifestParser do
  describe '#create_works' do
    subject(:xml_parser) { described_class.new(importer) }
    let(:importer) { FactoryBot.create(:bulkrax_importer_pbcore_manifest_xml) }
    let(:entry) { FactoryBot.create(:bulkrax_entry, importerexporter: importer) }
    let(:asset) { FactoryBot.create(:asset, id: 'cpb-aacip-20-000000hr')}

    before do
      Bulkrax.field_mappings['PbcoreManifestParser'] = {
        'bulkrax_identifier' => { from: ['instantiationIdentifier'], source_identifier: true },
        'generations' => { from: ["DigitalInstantiation.generations"] },
        'holding_organization' => { from: ["DigitalInstantiation.holding_organization"] }
      }
      allow_any_instance_of(PbcoreManifestParser).to receive(:manifest_hash).and_return(
        {"pbcore_instantiation_doc.xml"=>
          {"DigitalInstantiation.filename"=>
            "pbcore_instantiation_doc.xml",
           "Asset.id"=> asset.id,
           "DigitalInstantiation.generations"=>"Proxy",
           "DigitalInstantiation.holding_organization"=>
            "American Archive of Public Broadcasting",
           "DigitalInstantiation.aapb_preservation_lto"=>"AB0003",
           "DigitalInstantiation.aapb_preservation_disk"=>"ABDISK0004",
           "DigitalInstantiation.md5"=>
            "ac3d943e044e32f01de205f611227f0a"
          }
        }
      )
      allow(Bulkrax::XmlEntry).to receive_message_chain(:where, :first_or_create!).and_return(entry)
      allow(entry).to receive(:id)
      allow(Bulkrax::ImportWorkJob).to receive(:perform_later)
    end

    context 'with good data' do
      before do
        importer.parser_fields = {
          'import_file_path' => './spec/fixtures/bulkrax/xml/pbcore_instantiation_doc.xml',
          'record_element' => 'pbcoreInstantiationDocument'
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