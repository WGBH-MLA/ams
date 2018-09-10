class DescriptionTypesService < AMS::TypedFieldService
  TYPE = "description"
  AUTHORITY = "description_types"

  def initialize
    super(AUTHORITY,TYPE)
  end
end