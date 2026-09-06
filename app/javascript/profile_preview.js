let currentInput = null

function initPreview() {
  if (currentInput) {
    currentInput.removeEventListener("change", handleFileChange)
  }

  const input = document.getElementById("profile-picture-input")
  if (!input) return

  currentInput = input
  input.addEventListener("change", handleFileChange)
}

function handleFileChange(e) {
  const preview = document.getElementById("profile-preview")
  if (!preview) return

  const file = e.target.files[0]
  if (file) {
    const reader = new FileReader()
    reader.onload = (ev) => { preview.src = ev.target.result }
    reader.readAsDataURL(file)
  }
}

document.addEventListener("DOMContentLoaded", initPreview)
document.addEventListener("turbo:load", initPreview)
document.addEventListener("turbo:render", initPreview)
