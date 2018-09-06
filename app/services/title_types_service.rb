class TitleTypesService < AMS::TypedFieldService

  TYPE = "title"
  AUTHORITY = "title_types"

  def initialize
    super(AUTHORITY,TYPE)
  end

  # @param id of the field needs mapping to model
  # @return [String] Returns mapping for type to model field
  def model_field(id)
    case id
      when "episode_number"
        model_field = "episode_number"
    else
      model_field = super
    end
    model_field
  end
end