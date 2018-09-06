class DateTypesService < AMS::TypedFieldService
  TYPE = "date"
  AUTHORITY = "date_types"

  def initialize
    super(AUTHORITY,TYPE)
  end
end