import html2canvas from "html2canvas";

$(document).on('turbo:load', function () {
    for (let i = 0; i < 7; i++) {
        const button = $(`#dl-png-${i}`);

        button.on('click', function () {
            const screenshotTarget = $(`#tracklist-${i}`);
            html2canvas(screenshotTarget[0]).then((canvas) => {
                const base64image = canvas.toDataURL("image/png");
                var anchor = document.createElement('a');
                anchor.setAttribute("href", base64image);
                anchor.setAttribute("download", `tracklist-${i + 1}.png`);
                anchor.click();
                anchor.remove();
            });
        });
    }
});
