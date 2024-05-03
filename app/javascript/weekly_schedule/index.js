import html2canvas from "html2canvas";

$(document).on('turbo:load', function () {
    for (let i = 0; i < 7; i++) {
        document.getElementById(`dl-png-${i}`).onclick = function () {
            const screenshotTarget = document.getElementById(`tracklist-${i}`);

            html2canvas(screenshotTarget).then((canvas) => {
                const base64image = canvas.toDataURL("image/png");
                var anchor = document.createElement('a');
                anchor.setAttribute("href", base64image);
                anchor.setAttribute("download", `tracklist-${i + 1}.png`);
                anchor.click();
                anchor.remove();
            })
        }
    }
})
