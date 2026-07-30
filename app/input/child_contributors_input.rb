class ChildContributorsInput < MultiValueInput
  def build_field(value, index)
    contributor_role_service = ContributorRoleService.new
    role_choices = [""] + contributor_role_service.select_all_options

    input_dom_id_prefix = "#{object_name}_#{attribute_name}_#{index}"

    role_select_input_html_options = input_html_options.dup.merge(
      name: "#{@builder.object_name}[contributors][][contributor_role]",
      value: value[1],
      class: "select child_contributors form-control multi-select-field",
      id: input_dom_id_prefix + "_contributor_role",
    )

    contributor_text_input_html_options = input_html_options.dup.merge(
      name: "#{@builder.object_name}[contributors][][contributor]",
      value: value[2],
      placeholder: "Name",
      class: "string child_contributors form-control multi-text-field",
      id: input_dom_id_prefix + "_contributor"
    )

    contributor_role_annotation_html_options = input_html_options.dup.merge(
      name: "#{@builder.object_name}[contributors][][contributor_role_annotation]",
      value: value[3],
      placeholder: "Role Annotation",
      class: "string child_contributors form-control multi-text-field",
      id: input_dom_id_prefix + "_contributor_role_annotation"
    )

    portrayal_text_input_html_options = input_html_options.dup.merge(
      name: "#{@builder.object_name}[contributors][][portrayal]",
      value: value[4],
      placeholder: "Portrayal",
      class: "string child_contributors form-control multi-text-field",
      id: input_dom_id_prefix + "_portrayal"
    )

    affiliation_text_input_html_options = input_html_options.dup.merge(
      name: "#{@builder.object_name}[contributors][][affiliation]",
      value: value[5],
      placeholder: "Affiliation",
      class: "string child_contributors form-control multi-text-field",
      id: input_dom_id_prefix + "_affiliation"
    )
    
    affiliation_annotation_input_html_options = input_html_options.dup.merge(
      name: "#{@builder.object_name}[contributors][][affiliation_annotation]",
      value: value[6],
      placeholder: "Affiliation Annotation",
      class: "string child_contributors form-control multi-text-field",
      id: input_dom_id_prefix + "_affiliation_annotation"
    )

    annotation_text_input_html_options = input_html_options.dup.merge(
      name: "#{@builder.object_name}[contributors][][annotation]",
      value: value[7],
      placeholder: "Annotation",
      class: "string child_contributors form-control multi-text-field",
      id: input_dom_id_prefix + "_annotation"
    )

    start_time_input_html_options = input_html_options.dup.merge(
      name: "#{@builder.object_name}[contributors][][start_time]",
      value: value[8],
      placeholder: "Start Time",
      class: "string child_contributors form-control multi-text-field",
      id: input_dom_id_prefix + "_start_time"
    )

    end_time_input_html_options = input_html_options.dup.merge(
      name: "#{@builder.object_name}[contributors][][end_time]",
      value: value[9],
      placeholder: "End Time",
      class: "string child_contributors form-control multi-text-field",
      id: input_dom_id_prefix + "_end_time"
    )

    time_annotation_input_html_options = input_html_options.dup.merge(
      name: "#{@builder.object_name}[contributors][][time_annotation]",
      value: value[10],
      placeholder: "Time Annotation",
      class: "string child_contributors form-control multi-text-field",
      id: input_dom_id_prefix + "_time_annotation"
    )

    id_hidden_options = input_html_options.dup.merge(
        value: value[0],
        name: "#{@builder.object_name}[contributors][][id]",
        id: input_dom_id_prefix + "_id"
    )

    # Do not set the 'title_type' select to required, since blank option is allowed.
    # But 'title_value' needs to remain required if set.
    role_select_input_html_options.delete("required")
    role_select_input_html_options[:class].delete("required")
    portrayal_text_input_html_options.delete("required")
    portrayal_text_input_html_options[:class].delete("required")
    affiliation_text_input_html_options.delete("required")
    affiliation_text_input_html_options[:class].delete("required")
    annotation_text_input_html_options.delete("required")
    annotation_text_input_html_options[:class].delete("required")

    if contributor_text_input_html_options[:title_value].blank?
      if @rendered_first_element
        contributor_text_input_html_options.delete("required")
      end
      @rendered_first_element = true
    end

    output = @builder.hidden_field(:contributor_id, id_hidden_options)
    output += @builder.select(:contributor_role, role_choices, { selected: value[1] }, role_select_input_html_options)
    output += @builder.text_field(:contributor_name, contributor_text_input_html_options)
    output += @builder.text_field(:contributor_role_annotation, contributor_role_annotation_html_options)
    output += @builder.text_field(:affiliation, affiliation_text_input_html_options)
    output += @builder.text_field(:affiliation_annotation, affiliation_annotation_input_html_options)
    output += @builder.text_field(:portrayal, portrayal_text_input_html_options)
    output += @builder.text_field(:annotation, annotation_text_input_html_options)
    output += @builder.text_field(:start_time, start_time_input_html_options)
    output += @builder.text_field(:end_time, end_time_input_html_options)
    output += @builder.text_field(:time_annotation, time_annotation_input_html_options)
    output
  end
end
