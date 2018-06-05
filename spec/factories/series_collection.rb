FactoryBot.define do
  factory :series_collection, class: Collection do
    sequence(:series_title)         { |n| ["Test Series #{n}"] }
    sequence(:series_description)   { |n| ["This is a description of Test Series #{n}"] }
    sequence(:series_pbs_nola_code) { [ "ABC-DEFG #{sprintf '%06d', rand(10000)}" ] }
    # sequence(:series_start_date) { |n|  }
    # sequence(:series_end_date) { |n| ["This is a description of Test Series #{n}"] }
    # sequence(:series_eidr_id) { |n| ["This is a description of Test Series #{n}"] }
    # sequence(:series_annotation) { |n| ["This is a description of Test Series #{n}"] }
  end
end