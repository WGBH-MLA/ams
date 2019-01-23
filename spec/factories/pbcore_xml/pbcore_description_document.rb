require 'pbcore'

FactoryBot.define do
  factory :pbcore_description_document, class: PBCore::DescriptionDocument, parent: :pbcore_element do
    skip_create

    trait :full_aapb do
      audience_levels   { build_list(:pbcore_audience_level, rand(1..3)) }
      audience_ratings  { build_list(:pbcore_audience_rating, rand(1..3)) }
      asset_types       { build_list(:pbcore_asset_type, rand(1..3)) }
      annotations       { build_list(:pbcore_annotation, rand(1..3)) }
      subjects          { build_list(:pbcore_subject, rand(1..3)) }

      identifiers do
        [
          build(:pbcore_identifier, :aapb),
          build(:pbcore_identifier, :nola_code),
          build(:pbcore_identifier, :eidr),
          build(:pbcore_identifier, :local)
        ]
      end

      titles do
        [
          build_list(:pbcore_title, rand(1..3)),
          build_list(:pbcore_title, rand(1..3), type: 'Program'),
          build_list(:pbcore_title, rand(1..3), type: 'Episode'),
          build_list(:pbcore_title, rand(1..3), type: 'Segment'),
          build_list(:pbcore_title, rand(1..3), type: 'Promo'),
          build_list(:pbcore_title, rand(1..3), type: 'Clip'),
          build_list(:pbcore_title, rand(1..3), type: 'Raw Footage'),
          build(:pbcore_title, type: 'Episode Number', value: rand(1..500)),
        ].flatten
      end

      descriptions do
        [
          build_list(:pbcore_description, rand(1..3)),
          build_list(:pbcore_description, rand(1..3), type: 'Program'),
          build_list(:pbcore_description, rand(1..3), type: 'Episode'),
          build_list(:pbcore_description, rand(1..3), type: 'Segment'),
          build_list(:pbcore_description, rand(1..3), type: 'Promo'),
          build_list(:pbcore_description, rand(1..3), type: 'Clip'),
          build_list(:pbcore_description, rand(1..3), type: 'Raw Footage'),
        ].flatten
      end

      genres do
        [
          build_list(:pbcore_genre, rand(1..3)),
          build_list(:pbcore_genre, rand(1..3), :topic)
        ].flatten
      end

      coverages do
        [
          build(:pbcore_coverage, :spatial),
          build(:pbcore_coverage, :temporal)
        ]
      end

      rights_summaries do
        [
          build(:pbcore_rights_summary, :summary),
          build(:pbcore_rights_summary, :link)
        ]
      end

    end

    initialize_with { new(attributes) }
  end
end
