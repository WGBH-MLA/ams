class ChildContributorsInput < MultiValueInput
  def build_field(value, _index)

    contributor_role_service = ContributorRoleService.new
    role_choices = [""] + contributor_role_service.select_all_options

    role_select_input_html_options = input_html_options.dup.merge(
      name: "#{@builder.object_name}[contributors][][contributor_role]"
    )

    contributor_text_input_html_options = input_html_options.dup.merge(
      name: "#{@builder.object_name}[contributors][][contributor]",
      value: value[2],
      placeholder: "Name",
      class: "string child_contributors form-control multi-text-field"
    )

    portrayal_text_input_html_options = input_html_options.dup.merge(
      name: "#{@builder.object_name}[contributors][][portrayal]",
      value: value[3],
      placeholder: "Portrayal"
    )

    id_hidden_options = input_html_options.dup.merge(
        value: value[0],
        name: "#{@builder.object_name}[contributors][][id]"
    )


    # Do not set the 'title_type' select to required, since blank option is allowed.
    # But 'title_value' needs to remain required if set.
    role_select_input_html_options.delete(:required)
    role_select_input_html_options[:class].delete(:required)
    portrayal_text_input_html_options.delete(:required)
    portrayal_text_input_html_options[:class].delete(:required)

    if contributor_text_input_html_options[:title_value].blank?
      if @rendered_first_element
        contributor_text_input_html_options.delete(:required)
      end
      @rendered_first_element = true
    end

    output = @builder.hidden_field(:contributor_id, id_hidden_options)
    output += @builder.select(:contributor_role, role_choices, { selected: value[1] }, role_select_input_html_options)
    output += @builder.text_field(:contributor_name, contributor_text_input_html_options)
    output += @builder.text_field(:portrayal, portrayal_text_input_html_options)
    output
  end
end
