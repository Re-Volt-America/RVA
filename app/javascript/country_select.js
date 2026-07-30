function formatCountry(option) {
  if (!option.id) return option.text;
  const flag = document.createElement("i");
  flag.className = "twf twf-" + option.id.toLowerCase();
  flag.style.fontSize = "16px";
  flag.style.verticalAlign = "middle";
  flag.style.marginRight = "6px";
  return $("<span>").append(flag).append(" " + option.text);
}

function initCountrySelect() {
  const el = document.querySelector(".country-select");
  if (!el || el.dataset.select2Init) return;
  el.dataset.select2Init = "true";

  $(el).select2({
    theme: "dark",
    width: "100%",
    language: document.documentElement.lang || "en",
    templateResult: formatCountry,
    templateSelection: formatCountry
  });

  $(el).on("change", function () {
    el.dispatchEvent(new Event("change", { bubbles: true }));
  });
}

document.addEventListener("DOMContentLoaded", initCountrySelect);
document.addEventListener("turbo:load", initCountrySelect);
document.addEventListener("turbo:render", initCountrySelect);
