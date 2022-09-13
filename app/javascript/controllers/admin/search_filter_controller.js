import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    connect() {
        $(this.element).on("change", () => this.change())
    }

    change() {
        const delimiter = this.element.dataset.url.includes("?") ? "&" : "?";
        const url = this.element.value ?
            `${this.element.dataset.url}${delimiter}${this.element.name}=${this.element.value}`
        : this.element.dataset.url ;

        Turbo.visit(url);
    }
}
