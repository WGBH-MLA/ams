class FindSonyCiMediaBehavior
  # Select for the search button
  searchButtonSelector: '#find_sony_ci_media #search'
  # Selector for the div that displays the feedback messages.
  feedbackSelector: '#find_sony_ci_media #feedback'
  # Selector for the text inputs that have the Sony Ci IDs.
  sonyCiIdInputSelector: 'input.asset_resource_sonyci_id'
  # Selector for the button to add new Sony Ci IDs
  addNewSonyCiIdButtonSelector: '.form-group.asset_resource_sonyci_id button.add'

  constructor: (@query) ->

  # searchHandler - search Sony Ci for records matching the query and provide
  # feedback to the user.
  searchHandler: (event) =>
    event.preventDefault()
    @giveFeedback('searching...')
    $.ajax(
      context: this,
      url: "/sony_ci/api/find_media",
      data: { query: @query }
    ).done ( response ) ->
      @giveFeedback(response.length + ' records found')
      if response.length > 0
        @addFoundRecords(response)

  # fetchFilenameHandler - fetches the filename from Sony Ci given a Sony Ci ID
  # from an input field.
  fetchFilenameHandler: ->
    $.ajax(
      url: "/sony_ci/api/get_filename",
      context: this,
      data: { sony_ci_id: $(this).val() }
    ).done(( response ) ->
      $(this).parent().find('.sony_ci_filename').text(response['name'])
    ).fail(( response ) ->
      $(this).parent().find('.sony_ci_filename').text("Could not find Sony Ci record")
    )

  # Adds a message to give the user feedback on what's happening.
  # The element is hidden at first, so set the text and reveal it.
  giveFeedback: (msg) =>
    $(@feedbackSelector).text(msg).show()

  addFoundRecords: (records) =>
    # Map the sonyci_id text inputs to their values.
    existingSonyCiIds = $(@sonyCiIdInputSelector).map (_, element) ->
      $(element).val()

    # Map the found records to just the Sony Ci IDs.
    # This is not a jQuery.map function, so the index is the 2nd arg instead of
    # the first, like in the map function above.
    foundSonyCiIds = records.map (record, _) ->
      record['id']

    # Subtract the existing Sony Ci Ids from the found Sony Ci IDs.
    newSonyCiIds = $(foundSonyCiIds).not(existingSonyCiIds).get();

    # For each of the new found Sony Ci IDs...
    newSonyCiIds.forEach (sonyCiId, index) =>

      # Insert the found Sony Ci ID into the last text input and trigger the \
      # change() event, because just setting val(x) won't do it.
      $(@sonyCiIdInputSelector).last().val(sonyCiId).change()

      # If we have more Sony Ci IDs to add
      if newSonyCiIds.length > index
        # Add another Sony Ci ID field it by clicking the "Add another..."
        # button.
        $(@addNewSonyCiIdButtonSelector).click()

        # Hyrax will simply copy and append the last element, but we don't want
        # values for Sony Ci ID or Filename there, so clear them out.
        $(@sonyCiIdInputSelector).last().val('')
        $('.sony_ci_filename').last().text('')

        # Finally, add the handler to the change() event of the input.
        $(@sonyCiIdInputSelector).last().change @fetchFilenameHandler

  # apply - Attaches handlers to events.
  apply: ->
    # Attach the search handler to the click event of the search button.
    $(@searchButtonSelector).click @searchHandler
    # Attach the fetchFilenameHanlder to the change event of the inputs.
    $(@sonyCiIdInputSelector).change @fetchFilenameHandler

# When the page loads...
# NOTE: could not get $(document).on('turbolinks:load') to work on initial page
# load; reverting to $(document).ready, which seems to work more consistently.
$(document).ready ->
  # This regex matches the 3rd URL segment which should be the GUID.
  guid_query_str = window.location.href.match(/concern\/asset_resources\/(.*)\//)[1]

  # Create the behavior object, passing in the GUID as the query string.
  # NOTE: Sony Ci API has a 20 character limit on it's search terms, so let's
  # just pass in the last 20 characters, which will be more unique than the 1st
  # 20 chars due to the common prefix of "cpb-aacip-". Supposedly, Michael Potts
  # from Sony Ci said that quoted search queries have no such limit, but I could
  # not get that to work, nor is it mentioned in the Ci API docs anywhere.
  behavior = new FindSonyCiMediaBehavior(guid_query_str.substr(-20))

  # apply the behavior
  behavior.apply()
