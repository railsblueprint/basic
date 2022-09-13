import {Controller} from "@hotwired/stimulus"
import {useIntersection} from 'stimulus-use'

export default class extends Controller {
  static targets = ["button", "loader"]

  connect() {
    useIntersection(this)
  }

  appear(entry) {
    $(this.loaderTarget).removeClass('d-none');
    $(this.buttonTarget).addClass("d-none");
    this.buttonTarget.click();
  }
}
