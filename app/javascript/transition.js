document.addEventListener("DOMContentLoaded", () => {
  document.body.classList.add("page-loaded")
})

document.addEventListener("turbo:before-render", () => {
  document.body.classList.remove("page-loaded")
  document.body.classList.add("page-leaving")
})

document.addEventListener("turbo:render", () => {
  document.body.classList.remove("page-leaving")
  document.body.classList.add("page-loaded")
})

document.addEventListener("turbo:load", () => {
  document.body.classList.add("page-loaded")
  document.body.classList.remove("page-leaving")
})
