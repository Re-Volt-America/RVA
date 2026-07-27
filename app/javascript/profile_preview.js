document.addEventListener("change", (e) => {
  const preview = document.getElementById("profile-preview")
  if (!preview) return

  if (e.target.id === "profile-picture-input") {
    const checkbox = document.querySelector("input[type='checkbox'][name*='remove_profile_picture']")
    if (checkbox) checkbox.checked = false

    const file = e.target.files[0]
    if (file) {
      const reader = new FileReader()
      reader.onload = (ev) => { preview.src = ev.target.result }
      reader.readAsDataURL(file)
    }
  }

  if (e.target.name && e.target.name.includes("remove_profile_picture")) {
    const input = document.getElementById("profile-picture-input")
    if (e.target.checked) {
      preview.src = "/images/no_profile_picture.png"
      if (input) input.value = ""
    }
  }
})
