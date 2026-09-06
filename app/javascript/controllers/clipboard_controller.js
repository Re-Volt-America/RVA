import { Controller } from "@hotwired/stimulus"

// Small helper to copy text to the clipboard. The trigger element carries the
// text in a `data-clipboard-text` attribute and briefly shows a confirmation
// after copying. Used by the failed-import error dialog so admins can grab the
// full stack trace to share.
export default class extends Controller {
  copy(event) {
    const trigger = event.currentTarget
    const text = trigger.getAttribute("data-clipboard-text") || ""

    const done = () => this.flash(trigger)
    const fallback = () => this.copyFallback(text, done)

    if (navigator.clipboard && navigator.clipboard.writeText) {
      navigator.clipboard.writeText(text).then(done).catch(fallback)
    } else {
      fallback()
    }
  }

  copyFallback(text, done) {
    const area = document.createElement("textarea")
    area.value = text
    area.setAttribute("readonly", "")
    area.style.position = "absolute"
    area.style.left = "-9999px"
    document.body.appendChild(area)
    area.select()
    try {
      document.execCommand("copy")
    } catch (_e) {
      // Ignore — nothing more we can do without clipboard access.
    }
    document.body.removeChild(area)
    done()
  }

  flash(trigger) {
    const original = trigger.innerHTML
    trigger.innerHTML = '<i class="fa fa-check mr-1"></i>Copied'
    trigger.disabled = true
    setTimeout(() => {
      trigger.innerHTML = original
      trigger.disabled = false
    }, 1500)
  }
}
