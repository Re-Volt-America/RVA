function initCarStagger() {
  var container = document.querySelector("#cars, #car-cards-display, #tracks")
  if (!container) return

  var cards = container.querySelectorAll(".row > div")
  cards.forEach(function (card, i) {
    card.style.setProperty("--i", i)
  })

  requestAnimationFrame(function () {
    container.classList.add("animated")
  })
}

$(document).on("turbo:load", function () {
  initCarStagger()

  $("#input").on("keyup", function () {
    var value = $(this).val().toLowerCase()
    $(".car-card").filter(function () {
      $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1)
    })
  })
})
