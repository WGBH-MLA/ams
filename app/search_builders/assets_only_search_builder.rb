class AssetsOnlySearchBuilder < Hyrax::CatalogSearchBuilder
  def models
    [Asset]
  end
end
