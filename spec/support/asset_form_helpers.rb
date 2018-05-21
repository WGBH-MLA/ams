
# This module contains helper methods for use in Capybara specs that deal with
# entering data into the Asset create and edit forms.
# To use in your specs, add the metadata `asset_form_helpers: true` to
# your context or scenario.
module AssetFormHelpers

  # Fills in a title, and optionally selects a title type.
  # @param title [String] The title to enter.
  # @param type [String] The title type to select.
  # @param index [Integer] If there are multiple title/title_type pairs, use
  #  `index` to specify which pair you want to set.
  def fill_in_title_with_type(title, type: nil, index: nil)
    select_title_type(type, index: index) if type
    fill_in_title(title, index: index)
  end


  # Fills in multiple titles with their types.
  # @param Array titles_with_types An array where each element is a 2-element
  #  array containing the title and the title type.
  def fill_in_titles_with_types(titles_with_types)
    raise ArgumentError, "First argument must be enumerable, but #{titles_with_types.class} was given" unless titles_with_types.respond_to?(:each)
    titles_with_types.each_with_index do |title_with_type, index|
      raise ArgumentError, "Each element of first argument must be an array of 2 elements, but #{title_with_type} was given" unless (title_with_type.is_a?(Array) && title_with_type.count == 2)
      title, title_type = title_with_type
      fill_in_title_with_type(title, type: title_type)
      click_button 'Add another Title' unless (index+1 == titles_with_types.count)
    end
  end

  # Fills in a title.
  # @param title [String] The title.
  # @param index [Integer] If there are multiple titles, use
  #  `index` to specify which title you want to set. If no index is given
  #  it will set the last one found.
  def fill_in_title(title, index: nil)
    title_value_input(index).set title
  end

  # Selects a title type.
  # @param title_type [String] The title type option you want to select.
  # @param index [Integer] If there are multiple title types, use
  #  `index` to specify which title type you want to set. If no index is given
  #  it will set the last one found.
  def select_title_type(title_type, index: nil)
    title_type_select(index).select title_type
  end

  # Returns an input for entering a title.
  # @param index [Integer] If there are multiple titles, use
  #  `index` to specify which title you want to set. If no index is given
  #  it will set the last one found.
  def title_value_input(index=nil)
    # Get all inputs for entering titles.
    input_elements = page.all(:css, 'input[name="asset[title_value][]"]')
    # If no specific index was passed, return the last one found.
    index ||= input_elements.count - 1
    input_elements[index]
  end

  # Returns an element for selecting a title type.
  # @param index [Integer] If there are multiple title types, use
  #  `index` to specify which title type you want to set. If no index is given
  #  it will set the last one found.
  def title_type_select(index=nil)
    # Get all elements for selecting title types.
    select_elements = page.all(:css, 'select[name="asset[title_type][]"]')
    # If no specific index was passed, return the last one found.
    index ||= select_elements.count - 1
    select_elements[index]
  end

  # Fills in a description, and optionally selects a description type.
  # @param description [String] The description to enter.
  # @param type [String] The description type to select.
  # @param index [Integer] If there are multiple description/description_type pairs, use
  #  `index` to specify which pair you want to set.
  def fill_in_description_with_type(description, type: nil, index: nil)
    select_description_type(type, index: index) if type
    fill_in_description(description, index: index)
  end


  # Fills in multiple descriptions with their types.
  # @param Array descriptions_with_types An array where each element is a 2-element
  #  array containing the description and the description type.
  def fill_in_descriptions_with_types(descriptions_with_types)
    raise ArgumentError, "First argument must be enumerable, but #{descriptions_with_types.class} was given" unless descriptions_with_types.respond_to?(:each)
    descriptions_with_types.each_with_index do |description_with_type, index|
      raise ArgumentError, "Each element of first argument must be an array of 2 elements, but #{description_with_type} was given" unless (description_with_type.is_a?(Array) && description_with_type.count == 2)
      description, description_type = description_with_type
      fill_in_description_with_type(description, type: description_type)
      click_button 'Add another Description' unless (index+1 == descriptions_with_types.count)
    end
  end

  # Fills in a description.
  # @param description [String] The description.
  # @param index [Integer] If there are multiple descriptions, use
  #  `index` to specify which description you want to set. If no index is given
  #  it will set the last one found.
  def fill_in_description(description, index: nil)
    description_value_input(index).set description
  end

  # Selects a description type.
  # @param description_type [String] The description type option you want to select.
  # @param index [Integer] If there are multiple description types, use
  #  `index` to specify which description type you want to set. If no index is given
  #  it will set the last one found.
  def select_description_type(description_type, index: nil)
    description_type_select(index).select description_type
  end

  # Returns an input for entering a description.
  # @param index [Integer] If there are multiple descriptions, use
  #  `index` to specify which description you want to set. If no index is given
  #  it will set the last one found.
  def description_value_input(index=nil)
    # Get all inputs for entering descriptions.
    input_elements = page.all(:css, 'textarea[name="asset[description_value][]"]')
    # If no specific index was passed, return the last one found.
    index ||= input_elements.count - 1
    input_elements[index]
  end

  # Returns an element for selecting a description type.
  # @param index [Integer] If there are multiple description types, use
  #  `index` to specify which description type you want to set. If no index is given
  #  it will set the last one found.
  def description_type_select(index=nil)
    # Get all elements for selecting description types.
    select_elements = page.all(:css, 'select[name="asset[description_type][]"]')
    # If no specific index was passed, return the last one found.
    index ||= select_elements.count - 1
    select_elements[index]
  end

  # Fills in a date, and optionally selects a date type.
  # @param date [String] The date to enter.
  # @param type [String] The date type to select.
  # @param index [Integer] If there are multiple date/date_type pairs, use
  #  `index` to specify which pair you want to set.
  def fill_in_date_with_type(date, type: nil, index: nil)
    select_date_type(type, index: index) if type
    fill_in_date(date, index: index)
  end


  # Fills in multiple dates with their types.
  # @param Array dates_with_types An array where each element is a 2-element
  #  array containing the date and the date type.
  def fill_in_dates_with_types(dates_with_types)
    raise ArgumentError, "First argument must be enumerable, but #{dates_with_types.class} was given" unless dates_with_types.respond_to?(:each)
    dates_with_types.each_with_index do |date_with_type, index|
      raise ArgumentError, "Each element of first argument must be an array of 2 elements, but #{date_with_type} was given" unless (date_with_type.is_a?(Array) && date_with_type.count == 2)
      date, date_type = date_with_type
      fill_in_date_with_type(date, type: date_type)
      click_button 'Add another Description' unless (index+1 == dates_with_types.count)
    end
  end

  # Fills in a date, but first re-formats it to mm/dd/yyyy, which is the
  # format the date input accepts.
  # @param date [String] The date.
  # @param index [Integer] If there are multiple dates, use
  #  `index` to specify which date you want to set. If no index is given
  #  it will set the last one found.
  def fill_in_date(date, index: nil)
    mm_dd_yyyy = DateTime.parse(date).strftime("%m/%d/%Y")
    date_value_input(index).set mm_dd_yyyy
  end

  # Selects a date type.
  # @param date_type [String] The date type option you want to select.
  # @param index [Integer] If there are multiple date types, use
  #  `index` to specify which date type you want to set. If no index is given
  #  it will set the last one found.
  def select_date_type(date_type, index: nil)
    date_type_select(index).select date_type
  end

  # Returns an input for entering a date.
  # @param index [Integer] If there are multiple dates, use
  #  `index` to specify which date you want to set. If no index is given
  #  it will set the last one found.
  def date_value_input(index=nil)
    # Get all inputs for entering dates.
    input_elements = page.all(:css, 'input[name="asset[date_value][]"]')
    # If no specific index was passed, return the last one found.
    index ||= input_elements.count - 1
    input_elements[index]
  end

  # Returns an element for selecting a date type.
  # @param index [Integer] If there are multiple date types, use
  #  `index` to specify which date type you want to set. If no index is given
  #  it will set the last one found.
  def date_type_select(index=nil)
    # Get all elements for selecting date types.
    select_elements = page.all(:css, 'select[name="asset[date_type][]"]')
    # If no specific index was passed, return the last one found.
    index ||= select_elements.count - 1
    select_elements[index]
  end
end


# Include helper methods for all specs that are tagged with
# `include: :asset_form_helpers`
RSpec.configure do |config|
  config.include AssetFormHelpers, asset_form_helpers: true
end
