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
    parser_fields { { 'import_file_path' => 'spec/fixtures/csv/good.csv' } }
    field_mapping { {} }
    after :create, &:current_run
  end
end
