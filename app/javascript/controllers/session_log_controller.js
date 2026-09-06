import { Controller } from "@hotwired/stimulus"

// Shows the selected file name inside the session-log upload dropzone and
// accepts files dropped directly onto it.
export default class extends Controller {
  static targets = ["input", "filename"]

  connect() {
    this.preventDefaults = this.preventDefaults.bind(this)
    this.dragenter = this.dragenter.bind(this)
    this.dragleave = this.dragleave.bind(this)
    this.drop = this.drop.bind(this)

    this.element.addEventListener("dragover", this.preventDefaults)
    this.element.addEventListener("dragenter", this.dragenter)
    this.element.addEventListener("dragleave", this.dragleave)
    this.element.addEventListener("drop", this.drop)
  }

  disconnect() {
    this.element.removeEventListener("dragover", this.preventDefaults)
    this.element.removeEventListener("dragenter", this.dragenter)
    this.element.removeEventListener("dragleave", this.dragleave)
    this.element.removeEventListener("drop", this.drop)
  }

  preventDefaults(event) {
    event.preventDefault()
    event.stopPropagation()
  }

  dragenter(event) {
    this.preventDefaults(event)
    this.element.classList.add("has-file")
  }

  dragleave(event) {
    this.preventDefaults(event)
    this.element.classList.remove("has-file")
  }

  drop(event) {
    this.preventDefaults(event)
    this.element.classList.remove("has-file")

    const files = event.dataTransfer && event.dataTransfer.files
    const file = files && files[0]

    if (!file) return

    const input = this.inputTarget
    const transfer = new DataTransfer()
    transfer.items.add(file)
    input.files = transfer.files
    this.update()
  }

  update() {
    const input = this.inputTarget

    if (input.files && input.files.length > 0) {
      this.filenameTarget.textContent = input.files[0].name
      this.element.classList.add("has-file")
    } else {
      this.filenameTarget.textContent = ""
      this.element.classList.remove("has-file")
    }
  }
}
