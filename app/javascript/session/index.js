import html2canvas from "html2canvas";

$(document).on('turbo:load', function () {
    document.getElementById(`dl-png`).onclick = function () {
        const screenshotTarget = document.getElementById(`session`);

        html2canvas(screenshotTarget).then((canvas) => {
            const base64image = canvas.toDataURL("image/png");
            var anchor = document.createElement('a');
            anchor.setAttribute("href", base64image);
            anchor.setAttribute("download", `session.png`);
            anchor.click();
            anchor.remove();
        })
    }
})
