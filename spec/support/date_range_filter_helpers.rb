# Helper methods for testing the Date Range search filter.
# NOTE: These methods uses Capybara methods that will only work when called
# from a Capybara feature spec.
module DateRangeFilterHelpers
  # Conduct a search using the date range search filter.
  def search_by_date(exact: nil, after: nil, before: nil)
    # TODO: Go directly to search path unless already there.
    visit '/'
    find("#search-submit-header").click

    # If we can't see the facet panel body, then assume the facet is collapsed.
    unless page.has_content? '.blacklight-date_drsim .panel-body'
      # Click the facet heading to open the facet.
      find('.blacklight-date_drsim .panel-heading').click()
    end

    if exact
      choose 'exact_date_option'
      fill_in 'after_date', with: exact
    elsif (before || after)
      choose 'date_range_option'
      fill_in 'after_date', with: after
      fill_in 'before_date', with: before
    end

    # The date picker tends to obscure the 'Update' button so we need to
    # explicitly hide it here
    hide_date_picker_for '#after_date', '#before_date'

    # Submit the date range filter search.
    click_on 'Update'
  end

  # Hides the date picker for inputs specified by given selectors.
  def hide_date_picker_for(*input_selectors)
    input_selectors.each do |input_selector|
      execute_script("$('#{input_selector}').datepicker('hide')")
    end
  end

  def show_date_picker_for(*input_selectors)
    input_selectors.each do |input_selector|
      execute_script("$('#{input_selector}').datepicker('show')")
    end
  end
end

# Include this module
RSpec.configure { |c| c.include DateRangeFilterHelpers, type: :feature }
