$( document ).on('turbolinks:load', function() {
    $( ".datepicker" ).datepicker({
        dateFormat: "yy-mm-dd"
    });
});