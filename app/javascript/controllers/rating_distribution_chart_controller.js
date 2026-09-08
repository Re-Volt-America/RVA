import { Controller } from "@hotwired/stimulus"

// Gives the community-rating distribution chart a single-line tooltip
// ("N votes") instead of Chart.js's default title + value pair.
//
// Chartkick builds the chart from a JSON config that can't carry JS callbacks,
// so (like car_usage_chart_controller) we poll Chartkick's registry until the
// underlying Chart.js instance exists and then set the tooltip callback on it.
export default class extends Controller {
  static values = { chartId: String }

  connect() {
    this.attempts = 0
    this.poll = setInterval(() => this.tryBind(), 100)
    this.tryBind()
  }

  disconnect() {
    this.stopPolling()
    this.chart = null
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
      // Give up after ~5s; the chart still works, just without the custom tooltip.
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
    this.chart = chart

    const plugins = (chart.options.plugins = chart.options.plugins || {})
    const tooltip = (plugins.tooltip = plugins.tooltip || {})
    tooltip.enabled = true
    tooltip.displayColors = false
    tooltip.callbacks = tooltip.callbacks || {}
    // No title line: the star bucket is already the y-axis label.
    tooltip.callbacks.title = () => ""
    // A single line: the number of votes whose average landed on this star.
    tooltip.callbacks.label = (context) => {
      const value = context.raw
      return `${value.toLocaleString()} ${value === 1 ? "vote" : "votes"}`
    }

    chart.update("none")
  }
}
