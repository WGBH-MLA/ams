class MultipleTitlesWithTypesInput < AMS::MultiTypedInput

  def type_choices
    TitleTypesService.new.select_all_options
  end

  def fields_prefix
    "title"
  end
end
