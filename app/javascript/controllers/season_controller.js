import { Controller } from "@hotwired/stimulus"
import { get } from "@rails/request.js"

export default class extends Controller {
    static targets = ["rankingSelect"]

    change(e) {
        let season = e.target.selectedOptions[0].value
        let target = this.rankingSelectTarget.id

        get(`/sessions/rankings?target=${target}&season=${season}`, {
            responseKind: "turbo-stream"
        })
    }
}
