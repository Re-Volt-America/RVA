import { Controller } from "@hotwired/stimulus"
import { post } from "@rails/request.js"

// Drives the interactive star pickers on the track rating form and submits the form
// over Turbo Streams. Turbo Drive is disabled app-wide (see application.js), so the
// submission is performed manually here, mirroring app/javascript/controllers/season_controller.js.
export default class extends Controller {
    static targets = ["star", "input"]

    select(event) {
        const field = event.currentTarget.closest(".rating-field")
        const value = parseInt(event.currentTarget.dataset.value, 10)

        this.inputFor(field).value = value
        this.paint(field, value)
    }

    hover(event) {
        const field = event.currentTarget.closest(".rating-field")
        const value = parseInt(event.currentTarget.dataset.value, 10)

        this.paint(field, value)
    }

    reset(event) {
        const field = event.currentTarget.closest(".rating-field")

        this.paint(field, parseInt(this.inputFor(field).value, 10) || 0)
    }

    async submit(event) {
        event.preventDefault()

        await post(this.element.action, {
            body: new FormData(this.element),
            responseKind: "turbo-stream"
        })
    }

    inputFor(field) {
        return field.querySelector('[data-track-rating-target="input"]')
    }

    paint(field, value) {
        field.querySelectorAll('[data-track-rating-target="star"]').forEach((star) => {
            const starValue = parseInt(star.dataset.value, 10)

            star.classList.toggle("fa-star", starValue <= value)
            star.classList.toggle("fa-star-o", starValue > value)
        })
    }
}
