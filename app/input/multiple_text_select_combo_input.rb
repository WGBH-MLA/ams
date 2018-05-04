class MultipleTextSelectComboInput < MultiValueInput

  def build_field(value, index)
    # TODO: this data needs to come from a controlled vocab of title types
    # rather than being hardcoded here.
    title_type_choices = [
      ['', 'default'],
      ['Episode', 'episode'],
      ['Segment', 'segment'],
      ['Raw Footage', 'raw_footage'],
      ['Promo', 'promo'],
      ['Clip', 'clip']
    ]

    select_input_html_options = { name: "#{@builder.object_name}[title_type][]"}
    text_input_html_options = { name: "#{@builder.object_name}[title_value][]", value: value[1] }


    output = @builder.select(:title_type, title_type_choices, { selected: value[0] }, select_input_html_options)
    output += @builder.text_field(:title_value, text_input_html_options)
    output
  end


  # Overrides MultiValueInput#collection from Hydra-editor. The original
  # method calls object[attribute_name] instead of object.send(attribute_name)
  # to retrieve the value. By using the square brackets, it bypasses any
  # accessor method on the form object that you may have created to decorate
  # the values, which is exactly what we are doing.
  # TODO: Create a PR for hydra-editor to change `object[attribute_name]` to
  # `object.send(attribute_name)` in MultiValueInput#collection.
  def collection
    @collection ||= begin
      # As of this writing, the line below is the only once changed from the
      # original.
      val = object.send(attribute_name)
      col = val.respond_to?(:to_ary) ? val.to_ary : val
      col.reject { |value| value.to_s.strip.blank? } + ['']
    end
  end
end
