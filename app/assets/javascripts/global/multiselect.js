$( document ).on('turbolinks:load', function() {

    $("select[multiple='multiple']").children().each(function() {
        if ($(this).val() == "")
            $(this).remove();
    });

    $("select[multiple='multiple']").each(function() {
        $(this).multiselect();
    });
});
