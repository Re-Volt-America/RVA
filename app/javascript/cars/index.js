$(document).on('turbo:load', function () {
    $("#input").on("keyup", function() {
        const value = $(this).val().toLowerCase();
        $("#car-card").filter(function() {
            $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1)
        });
    });
})
