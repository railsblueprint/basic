import {Controller} from "@hotwired/stimulus"

export default class extends Controller {
    change() {
        const q = $(this.element).find("[name='q']")
        if (q.val() === "") {
            q.attr("disabled", true);
        }
        this.element.requestSubmit()
        q.attr("disabled", false);
    }
}
