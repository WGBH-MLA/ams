$(document).ready(function() {
  const $cleanTemplate = $('.form-group.child_contributors .listing li.field-wrapper').first().clone();
  $cleanTemplate.find('input[type="text"], select').val('');
  $cleanTemplate.find('input[type="hidden"]').remove();
  
  // Remove any existing click handlers from the add button
  // This is crucial to prevent double-firing of events
  $('.form-group.child_contributors').find('.add').off('click');
  
  $('.form-group.child_contributors').find('.add').on('click', function(e) {
    e.preventDefault();
    e.stopPropagation(); // Prevent event bubbling to other handlers
    
    const $listing = $('.form-group.child_contributors .listing');
    $listing.find('.has-warning, .message').remove();
    
    const $lastRow = $listing.find('li.field-wrapper:visible').last();
    
    const hasContent = Array.from($lastRow.find('input[type="text"], select')).some(
      input => input.value.trim() !== ''
    );
    
    let $newRow;
    if (hasContent) {
      // If last row has content, clone it but clear all values
      $newRow = $lastRow.clone();
      $newRow.find('input[type="text"], select').val('');
      $newRow.find('input[type="hidden"]').remove();
    } else {
      // If last row is empty, use the clean template
      $newRow = $cleanTemplate.clone();
    }
    
    $listing.append($newRow);
    
    $newRow.find('input, select').first().focus();
    
    return false;
  });
  
  $('.form-group.child_contributors').find('.remove').off('click');
  $('.form-group.child_contributors').find('.remove').on('click', function(e) {
    e.preventDefault();
    e.stopPropagation();
    
    const $wrapper = $(this).closest('li.field-wrapper');
    const $listing = $wrapper.parent();
    const $form = $('.edit_asset_resource');
    const contributorId = $wrapper.find('input[name$="[id]"]').val();
    
    if (contributorId && contributorId !== '') {
      const idInput = document.createElement('input');
      idInput.type = 'hidden';
      idInput.name = 'asset_resource[contributors][][id]';
      idInput.value = contributorId;
      
      const destroyInput = document.createElement('input');
      destroyInput.type = 'hidden';
      destroyInput.name = 'asset_resource[contributors][][_destroy]';
      destroyInput.value = 'true';
      
      $form[0].appendChild(idInput);
      $form[0].appendChild(destroyInput);
    }
    
    $wrapper.remove();
    
    if ($listing.find('li.field-wrapper').length === 0) {
      $listing.append($cleanTemplate.clone());
    }
    
    return false;
  });
  
  if (typeof FieldManager !== 'undefined') {
    FieldManager.prototype.displayEmptyWarning = function() { 
      // Do nothing - prevent warnings
    };
    
    // Completely disable the addToList method in FieldManager
    FieldManager.prototype.addToList = function(event) {
      event.preventDefault();
      event.stopPropagation();
      // Do nothing - prevent default behavior
      return false;
    };
  }
  
  $(document).on('DOMNodeInserted', '.form-group.child_contributors .add, .form-group.child_contributors .remove', function() {
    // Reattach our handlers
    $(this).off('click');
    
    if ($(this).hasClass('add')) {
      // Re-attach our add handler
      $(this).on('click', function(e) {
        e.preventDefault();
        e.stopPropagation();
        // Trigger the static handler
        $('.form-group.child_contributors').find('.add').first().trigger('click');
        return false;
      });
    }
    
    if ($(this).hasClass('remove')) {
      $(this).on('click', function(e) {
        e.preventDefault();
        e.stopPropagation();
        const $wrapper = $(this).closest('li.field-wrapper');
        const $listing = $wrapper.parent();
        const $form = $('.edit_asset_resource');
        const contributorId = $wrapper.find('input[name$="[id]"]').val();
        
        if (contributorId && contributorId !== '') {
          const idInput = document.createElement('input');
          idInput.type = 'hidden';
          idInput.name = 'asset_resource[contributors][][id]';
          idInput.value = contributorId;
          
          const destroyInput = document.createElement('input');
          destroyInput.type = 'hidden';
          destroyInput.name = 'asset_resource[contributors][][_destroy]';
          destroyInput.value = 'true';
          
          $form[0].appendChild(idInput);
          $form[0].appendChild(destroyInput);
        }
        
        $wrapper.remove();
        
        if ($listing.find('li.field-wrapper').length === 0) {
          $listing.append($cleanTemplate.clone());
        }
        
        return false;
      });
    }
  });
});
