Rails.application.config.after_initialize do
  Wings::ModelRegistry.register(AssetResource, Asset)
  Wings::ModelRegistry.register(PhysicalInstantiationResource, PhysicalInstantiation)
  Wings::ModelRegistry.register(DigitalInstantiationResource, DigitalInstantiation)
  Wings::ModelRegistry.register(EssenceTrackResource, EssenceTrack)
  Wings::ModelRegistry.register(ContributionResource, Contribution)
end
