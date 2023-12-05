FactoryBot.define do
  factory :asset_resource do
    sequence(:title)         { |n| ["Test Asset #{n}"] }
    sequence(:description)   { |n| ["This is a description of Test Asset #{n}"] }
    sequence(:bulkrax_identifier) { |n| "1-Assets-#{n}-#{n}"}
    annotation  { ['Sample Annotation'] }
    asset_types  { ['Clip','Promo'] }
    audience_level  {  ['PG14'] }
    audience_rating  { ['4.3'] }
    broadcast_date  { ["2010","2015-01","1987-10-31"] }
    clip_description  { ['Test clip_description'] }
    clip_title  { ['Test clip_title'] }
    copyright_date  { ["2010","2015-01","1987-10-31"] }
    created_date  { ["2010","2015-01","1987-10-31"] }
    date  { ["2010","2015-01","1987-10-31"] }
    eidr_id  { ['eidr_id-001'] }
    episode_description  { ['Test episode_description'] }
    episode_number  { ['S01E2'] }
    episode_title  { ['Test episode_title'] }
    genre  { ['Drama','Debate'] }
    local_identifier  { ['WGBH-11'] }
    pbs_nola_code  { ['PBS-WGBH-11'] }
    producing_organization  { ['Test producing_organization'] }
    program_description  { ['Test program_description'] }
    program_title  { ['Test program_title'] }
    promo_description  { ['Test promo_description'] }
    promo_title  { ['Test promo_title'] }
    raw_footage_description  { ['Test raw_footage_description'] }
    raw_footage_title  { ['Test raw_footage_title'] }
    rights_link  { ['http://www.google.com'] }
    rights_summary  { ['Sample rights_summary'] }
    segment_description  { ['Test segment_description'] }
    segment_title  { ['Test segment_title'] }
    spatial_coverage  { ['TEST spatial_coverage'] }
    subject  { ['Test subject'] }
    temporal_coverage  { ['Test temporal_coverage'] }
    topics  { ['Animals','Business'] }
    visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }

    transient do
      user { create(:user) }
      # Pass in AdminData.gid or it will create one for you!
      with_admin_data { false }
      # Pass in an AdminSet instance, or an admin set id, for example
      # create(:asset, admin_set: create(:admin_set))
      admin_set { false }
      needs_update { false }

      # This is where you would set the Asset's PhysicalInstantiations,
      # DigitalINstantiations, and/or Contributions
      members { [] }
      edit_users         { [] }
      edit_groups        { [] }
      read_users         { [] }
      visibility_setting { nil }
      with_index         { true }
      uploaded_files { [] }
    end



    trait :public do
      visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
    end

    trait :with_physical_instantiation_resource do
      members { [ create(:physical_instantiation_resource) ] }
    end

    trait :with_two_physical_instantiation_resources do
      members { [
        create(:physical_instantiation_resource),
        create(:minimal_physical_instantiation_resource)
      ] }
    end

    trait :with_digital_instantation_resource do
      members { [ create(:digital_instantation_resource) ] }
    end

    trait :with_digital_instantation_resource_and_essence_track_resource do
      members { [ create(:digital_instantation_resource, :aapb_moving_image_with_essence_track_resource) ] }
    end

    trait :with_two_digital_instantation_resources_and_essence_track_resources do
      members { [
        create(:digital_instantation_resource, :aapb_moving_image_with_essence_track_resource),
        create(:digital_instantation_resource, :aapb_moving_image_with_essence_track_resource)
      ] }
    end

    trait :with_physical_digital_and_essence_track_resource do
      members { [
        create(:physical_instantation_resource),
        create(:digital_instantation_resource, :aapb_moving_image_with_essence_track_resource),
      ] }
    end

    trait :family do
      members do
        [
          rand(2..4).times.map do
            create(:digital_instantation_resource,
              members: rand(2..4).times.map do
                create(:essence_track_resource)
              end
            )
          end,
          rand(1..2).times.map do
            create(:physical_instantation_resource,
              members: rand(2..4).times.map do
                create(:essence_track_resource)
              end
            )
          end,
          rand(2..4).times.map { create(:contribution_resource) }
        ].flatten
      end
    end

    before(:create) do |work, evaluator|
      if evaluator.admin_set
        work.admin_set_id = evaluator.admin_set.id
      end
    end

    after(:build) do |work, evaluator|
      if evaluator.with_admin_data
        attributes = {}
        work.admin_data_gid = evaluator.with_admin_data if !work.admin_data_gid.present?
      else
        if evaluator.needs_update
          admin_data = create(:admin_data, :needs_update)
        else
          admin_data = create(:admin_data)
        end

        work.admin_data_gid = admin_data.gid
      end

      if evaluator.visibility_setting
        Hyrax::VisibilityWriter
          .new(resource: work)
          .assign_access_for(visibility: evaluator.visibility_setting)
      end

      work.permission_manager.edit_groups = evaluator.edit_groups
      work.permission_manager.edit_users  = evaluator.edit_users
      work.permission_manager.read_users  = evaluator.read_users

      work.member_ids = evaluator.members.map(&:id) if evaluator.members
    end

    after(:create) do |work, evaluator|
      if evaluator.uploaded_files.present?
        Hyrax::WorkUploadsHandler.new(work: work).add(files: evaluator.uploaded_files).attach
        evaluator.uploaded_files.each do |file|
          allow(Hyrax.config.characterization_service).to receive(:run).and_return(true)
          # I don't love this - we might want to just run background jobs so
          # this is more real, but we'd have to stub some things.
          ValkyrieIngestJob.perform_now(file)
        end
      end

      work.permission_manager.edit_groups = evaluator.edit_groups
      work.permission_manager.edit_users  = evaluator.edit_users
      work.permission_manager.read_users  = evaluator.read_users

      # these are both no-ops if an active embargo/lease isn't present
      Hyrax::EmbargoManager.new(resource: work).apply
      Hyrax::LeaseManager.new(resource: work).apply

      if evaluator.visibility_setting
        work.permission_manager.acl.permissions = Set.new
        Hyrax::VisibilityWriter
          .new(resource: work)
          .assign_access_for(visibility: evaluator.visibility_setting)
      end

      work.permission_manager.acl.save
      Hyrax.index_adapter.save(resource: work) if evaluator.with_index
    end
  end
end
