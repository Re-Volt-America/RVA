import html2canvas from "html2canvas";

$(document).on('turbo:load', function () {
    const resultsTooltips = $('#results [data-toggle="tooltip"]');

    if (resultsTooltips.length === 0) {
        initScreenshot();
        return;
    }

    // Pre-load all images first to prevent positioning issues
    let imagesCount = 0;
    let loadedImages = 0;

    // Count images that need to be preloaded
    resultsTooltips.each(function() {
        const tooltipContent = $(this).attr('title');
        if (tooltipContent && tooltipContent.includes('<img')) {
            const imgSrc = tooltipContent.match(/src=['"]([^'"]+)['"]/);
            if (imgSrc && imgSrc[1]) {
                imagesCount++;
                const img = new Image();
                img.onload = function() {
                    loadedImages++;
                    if (loadedImages === imagesCount) {
                        initTooltips();
                    }
                };
                img.onerror = function() {
                    loadedImages++;
                    if (loadedImages === imagesCount) {
                        initTooltips();
                    }
                };
                img.src = imgSrc[1];
            }
        }
    });

    if (imagesCount === 0) {
        initTooltips();
    } else {
        // Safety timeout in case some images fail to load
        setTimeout(function() {
            if (loadedImages < imagesCount) {
                initTooltips();
            }
        }, 1000);
    }

    function initTooltips() {
        resultsTooltips.tooltip('dispose');

        resultsTooltips.tooltip({
            trigger: 'hover',
            html: true,
            delay: { "show": 200, "hide": 100 },
            animation: true,
            placement: 'top',
            template: '<div class="tooltip tooltip-results-custom" role="tooltip"><div class="arrow"></div><div class="tooltip-inner"></div></div>',
            container: 'body',
            popperConfig: {
                modifiers: {
                    preventOverflow: {
                        boundariesElement: 'viewport'
                    },
                    offset: {
                        offset: '0,10'
                    }
                }
            }
        });
    }

    initScreenshot();

    function initScreenshot() {
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
    }
});
