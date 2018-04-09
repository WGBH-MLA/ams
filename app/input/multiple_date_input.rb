class MultipleDateInput < MultiValueInput
  def build_field(value, index)
    options = build_field_options(value, index)
    @builder.date_field(attribute_name, options)
  end
end
