require_relative '../support/csv_builder'

FactoryBot.define do
  factory :csv, class: CsvBuilder do
    sequence(:path) { |n| "#{Dir.tmpdir}/test_data_#{n}.csv" }
    rows { [] }
    headers { nil }
    initialize_with { new(attributes) }
  end
end
