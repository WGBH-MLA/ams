# frozen_string_literal: true

FactoryBot.define do
  factory :bulkrax_importer, class: 'Bulkrax::Importer' do
    name { "A.N. Import" }
    admin_set_id { "MyString" }
    user { FactoryBot.build(:user) }
    frequency { "PT0S" }
    parser_klass { "Bulkrax::OaiDcParser" }
    limit { 10 }
    parser_fields do
      {
        'base_url' => 'http://commons.ptsem.edu/api/oai-pmh',
        'metadata_prefix' => 'oai_dc'
      }
    end
    field_mapping { [{}] }
  end

  factory :bulkrax_importer_csv, class: 'Bulkrax::Importer' do
    name { 'CSV Import' }
    admin_set_id { 'MyString' }
    user { FactoryBot.build(:user) }
    frequency { 'PT0S' }
    parser_klass { 'CsvParser' }
    limit { 10 }
    parser_fields { { 'import_file_path' => 'spec/fixtures/bulkrax/csv/good.csv' } }
    field_mapping { {} }
    after(:create) do |record|
      record.current_run
    end
  end

  factory :bulkrax_importer_pbcore_xml, class: 'Bulkrax::Importer' do
    name { 'PBCore Pbcore XML Import' }
    admin_set_id { 'MyString' }
    user { FactoryBot.build(:user) }
    frequency { 'PT0S' }
    parser_klass { 'PbcoreXmlParser' }
    limit { 10 }
    parser_fields { { 'import_file_path' => 'spec/fixtures/bulkrax/xml/pbcore_doc.xml' } }
    field_mapping do
      {
        'bulkrax_identifier' => { from: ['pbcoreIdentifier'], source_identifier: true }
      }
    end
  end

  factory :bulkrax_importer_pbcore_manifest_xml, class: 'Bulkrax::Importer' do
    name { 'PBCore Manifest Import' }
    admin_set_id { 'MyString' }
    user { FactoryBot.build(:user) }
    frequency { 'PT0S' }
    parser_klass { 'PbcoreManifestParser' }
    limit { 10 }
    parser_fields { { 'import_file_path' => 'spec/fixtures/bulkrax/xml/pbcore_instantiation_doc.xml' } }
    field_mapping do
      {
        'bulkrax_identifier' => { from: ['instantiationIdentifier'], source_identifier: true },
        'generations' => { from: ["DigitalInstantiation.generations"] },
        'holding_organization' => { from: ["DigitalInstantiation.holding_organization"] }
      }
    end
  end
end
