import html2canvas from "html2canvas";

$(document).on('turbo:load', function () {
    $(`#dl-png`).on('click', function () {
        const screenshotTarget = $(`#session`);

        html2canvas(screenshotTarget[0]).then((canvas) => {
            const base64image = canvas.toDataURL("image/png");
            var anchor = document.createElement('a');
            anchor.setAttribute("href", base64image);
            anchor.setAttribute("download", `session.png`);
            anchor.click();
            anchor.remove();
        });
    });
});
