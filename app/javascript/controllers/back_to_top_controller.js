import {Controller} from "@hotwired/stimulus";

export default class extends Controller {
    connect() {
        this.refresh();
    }

    refresh() {
        if (window.scrollY > 100) {
            this.element.classList.add("active");
        } else {
            this.element.classList.remove("active");
        }
    }

    click() {
        window.scrollTo(0, 0);
    }
}
