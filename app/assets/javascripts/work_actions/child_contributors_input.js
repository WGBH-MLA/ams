$(document).ready(function() {
  // Create and store a template row at initialization
  function createTemplateRow() {
    const $listing = $('.form-group.child_contributors .listing');
    const $firstRow = $listing.find('li.field-wrapper').first();
    const $template = $firstRow.clone();
    
    // Clear all inputs in the template
    $template.find('input[type="text"], select').val('');
    $template.find('input[type="hidden"]').remove();
    
    // Add a class to identify it as our template
    $template.addClass('template-row').hide();
    
    // Add it to the listing
    $listing.append($template);
  }

  // Create template row on page load
  createTemplateRow();

  // Handle remove button clicks
  $('.form-group.child_contributors').on('click', '.remove', function(e) {
    e.preventDefault();
    
    var $wrapper = $(this).closest('li.field-wrapper');
    var $listing = $wrapper.parent();
    var $form = $('.edit_asset_resource');
    var contributorId = $wrapper.find('input[name$="[id]"]').val();

    if (contributorId && contributorId !== '') {
      // Create hidden inputs
      var idInput = document.createElement('input');
      idInput.type = 'hidden';
      idInput.name = 'asset_resource[contributors][][id]';
      idInput.value = contributorId;

      var destroyInput = document.createElement('input');
      destroyInput.type = 'hidden';
      destroyInput.name = 'asset_resource[contributors][][_destroy]';
      destroyInput.value = 'true';

      // Append to form using vanilla JavaScript
      $form[0].appendChild(idInput);
      $form[0].appendChild(destroyInput);
    }

    // Remove the wrapper
    $wrapper.remove();
    
    // Remove any existing warning messages
    $listing.find('.has-warning').remove();

    // If this was the last visible row (excluding template), show the template
    if ($listing.find('li.field-wrapper:not(.template-row):visible').length === 0) {
      const $newRow = $listing.find('.template-row').clone();
      $newRow.removeClass('template-row').show();
      $listing.append($newRow);
    }
  });

  // Handle add button clicks
  $('.form-group.child_contributors').on('click', '.add', function(e) {
    e.preventDefault();
    const $listing = $(this).closest('.form-group').find('.listing');
    const $template = $listing.find('.template-row');
    
    // Remove any existing warning messages
    $listing.find('.has-warning').remove();
    
    if ($template.length) {
      const $newRow = $template.clone();
      $newRow.removeClass('template-row').show();
      $listing.append($newRow);
    }
  });

  // Override the FieldManager's validation message display
  if (typeof FieldManager !== 'undefined') {
    FieldManager.prototype.displayEmptyWarning = function() {
      // Do nothing - this prevents the warning from being displayed
    };
  }
});
