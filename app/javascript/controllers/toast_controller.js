import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    connect() {
        $(this.element).toast("show")
    }

    details() {
        $(".details").toggleClass("show")
    }
}
