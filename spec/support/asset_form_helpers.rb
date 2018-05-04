
# This module contains helper methods for use in Capybara specs that deal with
# entering data into the Asset create and edit forms.
# To use in your specs, add the metadata `include: :asset_form_helpers` to
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
end


# Include helper methods for all specs that are tagged with
# `include: :asset_form_helpers`
RSpec.configure do |config|
  config.include AssetFormHelpers, include: :asset_form_helpers
end
