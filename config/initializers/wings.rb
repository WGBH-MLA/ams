# frozen_string_literal: true
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
  Wings::ModelRegistry.register(Collection, Collection)
  Wings::ModelRegistry.register(Hyrax::PcdmCollection, Collection)
  Wings::ModelRegistry.register(Hyrax::AdministrativeSet, AdminSet)
  Wings::ModelRegistry.register(AdminSet, AdminSet)

  Valkyrie::MetadataAdapter.register(
    Freyja::MetadataAdapter.new,
    :freyja
  )
  Valkyrie.config.metadata_adapter = :freyja
  Hyrax.config.query_index_from_valkyrie = true
  Hyrax.config.index_adapter = :solr_index

  Valkyrie::StorageAdapter.register(
    Valkyrie::Storage::Disk.new(base_path: Rails.root.join("storage", "files"),
      file_mover: FileUtils.method(:cp)),
    :disk
  )
  Valkyrie.config.storage_adapter  = :disk
  Valkyrie.config.indexing_adapter = :solr_index


  # load all the sql based custom queries
  [
    Hyrax::CustomQueries::Navigators::CollectionMembers,
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
    Hyrax::CustomQueries::FindByDateRange,
    Hyrax::CustomQueries::FindByBulkraxIdentifier,
  ].each do |handler|
    Hyrax.query_service.services[0].custom_queries.register_query_handler(handler)
  end

  [
    Wings::CustomQueries::FindByBulkraxIdentifier
  ].each do |handler|
    Hyrax.query_service.services[1].custom_queries.register_query_handler(handler)
  end

  Wings::ModelRegistry.register(AssetResource, Asset)
  Wings::ModelRegistry.register(PhysicalInstantiationResource, PhysicalInstantiation)
  Wings::ModelRegistry.register(DigitalInstantiationResource, DigitalInstantiation)
  Wings::ModelRegistry.register(EssenceTrackResource, EssenceTrack)
  Wings::ModelRegistry.register(ContributionResource, Contribution)

  Hyrax::Transactions::Container.merge(Ams::Container)
  Hyrax::Transactions::Container.merge(Bulkrax::Container)
end

Rails.application.config.to_prepare do
  Hyrax::AdministrativeSet.class_eval do
    attribute :internal_resource, Valkyrie::Types::Any.default("AdminSet".freeze), internal: true
  end

  Hyrax::PcdmCollection.class_eval do
    attribute :internal_resource, Valkyrie::Types::Any.default("Collection".freeze), internal: true
  end


  Hyrax::FileSet.class_eval do
    attribute :internal_resource, Valkyrie::Types::Any.default("FileSet".freeze), internal: true
  end

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
    elsif 'Collection' == klass_name
      Hyrax::PcdmCollection
    elsif 'AdminSet' == klass_name
      Hyrax::AdministrativeSet
    else
      klass_name.constantize
    end
  end
end
