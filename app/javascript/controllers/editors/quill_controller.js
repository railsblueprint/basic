import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = {
    options: Object,
  };

  connect() {
    console.log('Connecting to')
    new Quill(this.element, { ...this.optionsValue });
  }
}
