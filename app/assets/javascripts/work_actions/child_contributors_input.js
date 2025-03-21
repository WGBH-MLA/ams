$(document).ready(function() {
  var $template = $('.form-group.child_contributors .listing li.field-wrapper').first().clone();
  
  $('.form-group.child_contributors .has-warning, .form-group.child_contributors .message.has-warning').remove();
  
  $('.form-group.child_contributors .add').off('click');
  
  $('.form-group.child_contributors .remove').on('click', function(e) {
    var $wrapper = $(this).closest('li.field-wrapper');
    var contributorId = $wrapper.find('input[name$="[id]"]').val();

    if (contributorId && contributorId !== '') {
      var $form = $(this).closest('form');

      var idInput = $('<input>')
        .attr('type', 'hidden')
        .attr('name', 'asset_resource[contributors][][id]')
        .val(contributorId);

      var destroyInput = $('<input>')
        .attr('type', 'hidden')
        .attr('name', 'asset_resource[contributors][][_destroy]')
        .val('true');

      $form.append(idInput);
      $form.append(destroyInput);
    }

    $wrapper.remove();
  });

  // Override the hydra-editor's warning display function
  if (typeof FieldManager !== 'undefined') {
    FieldManager.prototype.displayEmptyWarning = function() {
      // Do nothing - this prevents the warning from being displayed
    };
  }

  $('.form-group.child_contributors .add').on('click', function(e) {
    e.preventDefault(); // Prevent default hydra-editor behavior
    e.stopPropagation();
    
    $('.form-group.child_contributors .has-warning, .form-group.child_contributors .message.has-warning').remove();
    
    var $listing = $(this).closest('.form-group.child_contributors').find('.listing');
    
    var $templateToUse = $listing.children('li.field-wrapper').last().length > 0 
      ? $listing.children('li.field-wrapper').last()
      : $template;
    
    var $newField = $templateToUse.clone();
    $newField.find('input').val('').removeAttr('required');
    
    $listing.append($newField);
    
    $newField.find('input').first().focus();
  });
});
