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

            // html2canvas does not support `background-clip: text`, so gradient
            // team names (color: transparent) would render as an empty color bar.
            // Temporarily switch them to a solid color for the capture.
            const teamLinks = $(`#session .team-col a`);
            const originals = [];

            teamLinks.each(function () {
                const style = $(this).attr('style');
                const match = style && style.match(/linear-gradient\([^,]+,\s*(#[0-9a-fA-F]{6})/);
                originals.push({ el: this, style });
                $(this).attr('style', `color: ${match ? match[1] : '#ffffff'};`);
            });

            // html2canvas composites empty (transparent) `.pos`, `.car`, and
            // class-less spacer cells against a dark backdrop instead of the
            // table background, so rows with many blank positions (e.g. lower
            // DNF-heavy racers, or the per-track car cells in teams tables)
            // come out as dark bands. Give them the opaque table background
            // for the capture.
            const captureStyles = $(
                `<style id="session-capture-styles">
                    #session .pos { background-color: #1a2835 !important; }
                    #session .car { background-color: #1a2835 !important; }
                    #session td:not([class]) { background-color: #1a2835 !important; }
                 </style>`
            ).appendTo('head');

            function restoreCaptureState() {
                originals.forEach(function (item) {
                    $(item.el).attr('style', item.style);
                });
                captureStyles.remove();
            }

            html2canvas(screenshotTarget[0]).then((canvas) => {
                restoreCaptureState();
                const base64image = canvas.toDataURL("image/png");
                var anchor = document.createElement('a');
                anchor.setAttribute("href", base64image);
                anchor.setAttribute("download", `session.png`);
                anchor.click();
                anchor.remove();
            }).catch(() => {
                restoreCaptureState();
            });
        });
    }
});
