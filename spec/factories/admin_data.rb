FactoryBot.define do
  factory :admin_data, class: AdminData do
    level_of_user_access { "Online Reading Room" }
    minimally_cataloged { "Yes" }
    outside_url { "http://www.someoutsideurl.com/" }
    special_collection { ["Collection1","Collection2"] }
    transcript_status { "Indexing Only Transcript" }
    sonyci_id { ["Sony-1","Sony-2"] }
    licensing_info { "Licensing Info" }
    organization { "American Archive of Public Broadcasting" }
    special_collection_category { ["Outside"] }
    canonical_meta_tag { nil }
    trait :no_sony_ci_id do
      sonyci_id { [] }
    end
    trait :one_sony_ci_id do
      sonyci_id {["Sony-1"] }
    end

    trait :needs_update do
      needs_update {true}
    end

    trait :empty do
      level_of_user_access { nil }
      minimally_cataloged { nil }
      outside_url { nil }
      special_collection { [] }
      transcript_status { nil }
      sonyci_id { [] }
      licensing_info { nil }
      organization { nil }
      special_collection_category { [] }
      canonical_meta_tag { nil }
    end
  end
end
