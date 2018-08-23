$('.multi_value.form-group', $("form[data-behavior='work-form']")[0]).on('managed_field:add', function (e,child) {
    if(child) {
        $(child).attr("id", child.id + "_" + $.now());
        if ($(child).hasClass("hasDatepicker")) {
            $(child).removeClass("datepicker hasDatepicker");
            $(child).datepicker({
                dateFormat: "yy-mm-dd"
            });
        }
    }
});