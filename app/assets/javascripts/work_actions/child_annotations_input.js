$(document).ready(function() {
  var $template = $('.form-group.child_annotations .listing li.field-wrapper').first().clone();
  
  $('.form-group.child_annotations .has-warning, .form-group.child_annotations .message.has-warning').remove();
  
  $('.form-group.child_annotations .add').off('click');
  
  $('.form-group.child_annotations .remove').on('click', function(e) {
    var $wrapper = $(this).closest('li.field-wrapper');
    var annotationId = $wrapper.find('input[name$="[id]"]').val();

    if (annotationId && annotationId !== '') {
      var $form = $(this).closest('form');

      var idInput = $('<input>')
        .attr('type', 'hidden')
        .attr('name', 'asset_resource[annotations][][id]')
        .val(annotationId);

      var destroyInput = $('<input>')
        .attr('type', 'hidden')
        .attr('name', 'asset_resource[annotations][][_destroy]')
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

  $('.form-group.child_annotations .add').on('click', function(e) {
    e.preventDefault(); // Prevent default hydra-editor behavior
    e.stopPropagation();
    
    $('.form-group.child_annotations .has-warning, .form-group.child_annotations .message.has-warning').remove();
    
    var $listing = $(this).closest('.form-group.child_annotations').find('.listing');
    
    var $templateToUse = $listing.children('li.field-wrapper').last().length > 0 
      ? $listing.children('li.field-wrapper').last()
      : $template;
    
    var $newField = $templateToUse.clone();
    $newField.find('input').val('').removeAttr('required');
    
    $listing.append($newField);
    
    $newField.find('input').first().focus();
  });
});
