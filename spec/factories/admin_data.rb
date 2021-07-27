FactoryBot.define do
  factory :admin_data, class: AdminData do
    sonyci_id { ["Sony-1","Sony-2"] }

    trait :one_sony_ci_id do
      sonyci_id {["Sony-1"] }
    end

    trait :needs_update do
      needs_update {true}
    end

    trait :empty do
      hyrax_batch_ingest_batch_id { nil }
      last_pushed { nil }
      last_updated { nil }
      needs_update { nil }
      sonyci_id { [] }
    end

    trait :with_annotation do
      after(:create) do |ad|
        create(:annotation, admin_data_id: ad.id)
      end
    end

    trait :with_special_collections_annotation do
      after(:create) do |ad|
        create(:annotation, admin_data_id: ad.id, annotation_type: 'special_collections', value: 'Collection1')
      end

    end

    after(:build) do |ad, evaluator|
      if evaluator.annotations.present?
        ad.annotations = evaluator.annotations
      end
    end
  end
end
