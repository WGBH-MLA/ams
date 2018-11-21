FactoryBot.define do
  factory :admin_data, class: AdminData do
    level_of_user_access "Online Reading Room"
    minimally_cataloged "Yes"
    outside_url "http://www.someoutsideurl.com/"
    special_collection ["Collection1","Collection2"]
    transcript_status "Indexing Only Transcript"
    sonyci_id ["Sony-1","Sony-2"]
    licensing_info "Licensing Info"
    trait :no_sony_ci_id do
      sonyci_id []
    end
  end
end
