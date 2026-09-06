import { Controller } from "@hotwired/stimulus"

// Drives the "Importing your session" progress screen shown after a Session log
// upload. It polls the import's JSON status endpoint and animates a progress
// bar. Because parsing progress is reported as coarse milestones (queued ->
// processing -> completed), the bar eases smoothly toward a ceiling derived
// from the current status so it always feels alive. On success it fills to
// 100% and forwards to the parsed Session's results page; on failure it turns
// red and reveals the error message.
export default class extends Controller {
  static targets = ["bar", "percent", "label", "error", "errorMessage"]
  static values = {
    url: String,
    interval: { type: Number, default: 1500 }
  }

  connect() {
    this.displayed = 0
    this.ceiling = 8      // creep a little immediately so it never starts frozen
    this.finished = false

    this.tick = this.tick.bind(this)
    this.raf = requestAnimationFrame(this.tick)

    this.poll()
    this.timer = setInterval(() => this.poll(), this.intervalValue)
  }

  disconnect() {
    if (this.timer) clearInterval(this.timer)
    if (this.raf) cancelAnimationFrame(this.raf)
  }

  // Animation loop: ease the displayed value toward the current ceiling.
  tick() {
    if (this.displayed < this.ceiling) {
      const step = Math.max(0.15, (this.ceiling - this.displayed) * 0.05)
      this.displayed = Math.min(this.ceiling, this.displayed + step)
      this.render()
    }
    this.raf = requestAnimationFrame(this.tick)
  }

  render() {
    const pct = Math.min(100, Math.round(this.displayed))
    this.barTarget.style.width = `${pct}%`
    this.barTarget.setAttribute("aria-valuenow", pct)
    if (this.hasPercentTarget) this.percentTarget.textContent = `${pct}%`
  }

  async poll() {
    if (this.finished) return

    try {
      const response = await fetch(this.urlValue, {
        headers: { Accept: "application/json" },
        credentials: "same-origin"
      })
      if (!response.ok) return
      this.apply(await response.json())
    } catch (_e) {
      // Transient network/server hiccup — keep polling.
    }
  }

  apply(data) {
    if (data.completed) {
      this.succeed(data)
    } else if (data.failed) {
      this.fail(data)
    } else if (data.status === "processing") {
      this.ceiling = 90
      this.setLabel("Parsing session...")
    } else {
      this.ceiling = 18
      this.setLabel("Queued...")
    }
  }

  succeed(data) {
    if (this.finished) return
    this.finished = true
    if (this.timer) clearInterval(this.timer)
    this.setLabel("Done! Redirecting...")

    // Fill the bar to 100% before navigating so the completion reads clearly.
    const fill = () => {
      if (this.displayed >= 99.5) {
        this.displayed = 100
        this.render()
        if (data.session_url) {
          window.location.href = data.session_url
        }
        return
      }
      this.displayed = Math.min(100, this.displayed + Math.max(0.6, (100 - this.displayed) * 0.18))
      this.render()
      requestAnimationFrame(fill)
    }
    if (this.raf) cancelAnimationFrame(this.raf)
    requestAnimationFrame(fill)
  }

  fail(data) {
    if (this.finished) return
    this.finished = true
    if (this.timer) clearInterval(this.timer)
    if (this.raf) cancelAnimationFrame(this.raf)

    this.barTarget.classList.remove("progress-bar-animated", "progress-bar-striped")
    this.barTarget.classList.add("bg-danger")
    this.setLabel("Import failed")

    if (this.hasErrorTarget) {
      this.errorTarget.classList.remove("d-none")
      if (this.hasErrorMessageTarget && data.error_message) {
        this.errorMessageTarget.textContent = data.error_message
      }
    }
  }

  setLabel(text) {
    if (this.hasLabelTarget) this.labelTarget.textContent = text
  }
}
