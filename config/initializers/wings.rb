# frozen_string_literal: true
unless App.rails_5_1?
  Rails.application.config.after_initialize do
    [
      Asset,
      PhysicalInstantiation,
      DigitalInstantiation,
      EssenceTrack,
      Contribution
    ].each do |klass|
      Wings::ModelRegistry.register("#{klass}Resource".constantize, klass)
      # we register itself so we can pre-translate the class in Freyja instead of having to translate in each query_service
      Wings::ModelRegistry.register(klass, klass)
    end

    Valkyrie::MetadataAdapter.register(
      Freyja::MetadataAdapter.new,
      :freyja
    )
    Valkyrie.config.metadata_adapter = :freyja

    Valkyrie::StorageAdapter.register(
      Valkyrie::Storage::Disk.new(base_path: Rails.root.join("storage", "files"),
        file_mover: FileUtils.method(:cp)),
      :disk
    )
    Valkyrie.config.storage_adapter  = :disk
    Valkyrie.config.indexing_adapter = :solr_index


    # load all the sql based custom queries
    custom_queries = [Hyrax::CustomQueries::Navigators::CollectionMembers,
      Hyrax::CustomQueries::Navigators::ChildCollectionsNavigator,
      Hyrax::CustomQueries::Navigators::ParentCollectionsNavigator,
      Hyrax::CustomQueries::Navigators::ChildFileSetsNavigator,
      Hyrax::CustomQueries::Navigators::ChildWorksNavigator,
      Hyrax::CustomQueries::Navigators::FindFiles,
      Hyrax::CustomQueries::FindAccessControl,
      Hyrax::CustomQueries::FindCollectionsByType,
      Hyrax::CustomQueries::FindFileMetadata,
      Hyrax::CustomQueries::FindIdsByModel,
      Hyrax::CustomQueries::FindManyByAlternateIds,
      Hyrax::CustomQueries::FindModelsByAccess,
      Hyrax::CustomQueries::FindCountBy,
      Hyrax::CustomQueries::FindByDateRange]
    custom_queries.each do |handler|
      Hyrax.query_service.services[0].custom_queries.register_query_handler(handler)
    end


  end

  Rails.application.config.to_prepare do
    Valkyrie.config.resource_class_resolver = lambda do |resource_klass_name|
      klass_name = resource_klass_name.gsub(/Resource$/, '')
      if %w[
        Asset
        PhysicalInstantiation
        DigitalInstantiation
        EssenceTrack
        Contribution
      ].include?(klass_name)
        "#{klass_name}Resource".constantize
      else
        klass_name.constantize
      end
    end
  end
end
