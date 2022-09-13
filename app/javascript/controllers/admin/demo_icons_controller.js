import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  search() {
    const q = $(this.element).find("[name=\"q\"]").val()

    $(this.element).find(".icon").addClass("d-none")
    $(this.element).find(".icon-category").addClass("d-none");

    $(this.element).find(`.icon:contains(${q})`).removeClass("d-none")
        .parents(".icon-category").removeClass("d-none");
      }
}
