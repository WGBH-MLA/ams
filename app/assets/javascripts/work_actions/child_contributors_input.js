$(document).ready(function() {
  $('.form-group.child_contributors .remove').on('click', function(e) {
    var $wrapper = $(this).closest('li.field-wrapper');
    var contributorId = $wrapper.find('input[name$="[id]"]').val();

    if (contributorId && contributorId !== '') {
      var $form = $(this).closest('form');

      // Create a hidden input for the ID
      var idInput = $('<input>')
        .attr('type', 'hidden')
        .attr('name', 'asset_resource[contributors][][id]')
        .val(contributorId);

      // Create a hidden input for _destroy flag
      var destroyInput = $('<input>')
        .attr('type', 'hidden')
        .attr('name', 'asset_resource[contributors][][_destroy]')
        .val('true');

      // Add them to the form
      $form.append(idInput);
      $form.append(destroyInput);
    }

    $wrapper.remove();
  });
});
