import {Controller} from "@hotwired/stimulus"

export default class extends Controller {

  connect( ){
    $(document).on("keydown", this.keydown.bind(this));
  }

  disconnect( ){
    $(document).off("keydown", this.keydown.bind(this));
  }

  keydown(e) {
    if (e.code === "KeyS" && e.metaKey) {
      e.preventDefault();
      e.stopPropagation();
      this.element.click();
    }
  }
}
