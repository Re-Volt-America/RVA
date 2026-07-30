import { Controller } from "@hotwired/stimulus"

// Adds interactivity to the season car-usage bar chart on the admin stats page.
//
//   - Hover highlighting is declared in the view (Chart.js `hoverBackgroundColor`
//     on the dataset), so it works without any JS here.
//   - This controller reaches into the underlying Chart.js instance (created by
//     Chartkick) to give bars a pointer cursor and, on click, to highlight and
//     scroll to the matching car's row in the table below.
//
// The chart renders asynchronously, so we poll Chartkick's registry briefly
// until the instance exists rather than assuming it is ready on connect().
export default class extends Controller {
  static targets = ["row"]
  static values = { chartId: String }

  connect() {
    this.attempts = 0
    this.poll = setInterval(() => this.tryBind(), 100)
    this.tryBind()
  }

  disconnect() {
    this.stopPolling()
  }

  stopPolling() {
    if (this.poll) {
      clearInterval(this.poll)
      this.poll = null
    }
  }

  tryBind() {
    this.attempts += 1
    const chart = this.chartObject()

    if (chart) {
      this.stopPolling()
      this.bind(chart)
    } else if (this.attempts > 50) {
      // Give up after ~5s; the page still works without the interactivity.
      this.stopPolling()
    }
  }

  // Resolve the Chart.js instance that Chartkick created for our element id.
  chartObject() {
    const registry = window.Chartkick && window.Chartkick.charts
    const chart = registry && registry[this.chartIdValue]
    if (!chart || typeof chart.getChartObject !== "function") return null
    return chart.getChartObject()
  }

  bind(chart) {
    // Pointer cursor while hovering a bar.
    chart.options.onHover = (event, elements) => {
      const canvas = event.native && event.native.target
      if (canvas) canvas.style.cursor = elements.length ? "pointer" : "default"
    }

    // Click a bar -> highlight and scroll to that car's row.
    chart.options.onClick = (_event, elements) => {
      if (!elements.length) return
      const label = chart.data.labels[elements[0].index]
      this.focusRow(label)
    }

    // The x-axis shows bare numbers now, so restore the unit in the tooltip.
    const tooltip = (chart.options.plugins = chart.options.plugins || {}).tooltip || {}
    tooltip.callbacks = tooltip.callbacks || {}
    tooltip.callbacks.label = (context) => {
      const value = context.parsed.x
      return `${value} ${value === 1 ? "time" : "times"} used`
    }
    chart.options.plugins.tooltip = tooltip

    chart.update("none")
  }

  // Whole-row shortcut to the car page. Clicks on the real link inside the row
  // are left alone so the anchor handles them normally.
  openCar(event) {
    if (event.target.closest("a")) return

    const path = event.currentTarget.dataset.carPath
    if (path) window.location = path
  }

  focusRow(carName) {
    const match = this.rowTargets.find((row) => row.dataset.car === carName)

    this.rowTargets.forEach((row) => row.classList.remove("car-usage-row--active"))
    if (!match) return

    // Re-trigger the CSS flash even if the same row is clicked twice.
    void match.offsetWidth
    match.classList.add("car-usage-row--active")
    match.scrollIntoView({ behavior: "smooth", block: "center" })
  }
}
