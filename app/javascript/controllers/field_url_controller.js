import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const field = $(this.element);
    const urlPrefix = $(field).data("url-prefix") || "";
    const local = $(field).data("local");
    const value = $(field).siblings("input").val();
    $(field).attr("href", urlPrefix + value);

    $(field).siblings("input").on("change, input", (e) => {
      var start = e.target.selectionStart;
      var end = e.target.selectionEnd;
      const value = $(e.currentTarget).val();

      // Removes starting slashes
      if (local && value[0].match(/^\/+/)) {
        const new_value = value.replace(/^\/+/, "");
        const removed = value.length - new_value.length;
        $(e.currentTarget).val(new_value);
        $(e.currentTarget)[0].setSelectionRange(start - removed ,end - removed )
        field.attr("href", urlPrefix + new_value);
      } else {
        field.attr("href", urlPrefix + value);
      }
    })
  }
}
