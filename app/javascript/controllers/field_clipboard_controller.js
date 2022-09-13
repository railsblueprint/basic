import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  click(e) {
    e.preventDefault();
    e.stopPropagation();

    const button = $(e.currentTarget) ;
    const parent = button.parent(".input-group");
    const value = parent.find("input[type='text']")[0].value;
    const success_message = button.data("success");
    const failure_message = button.data("failure");
    const original_title = button.data("bs-original-title");
    navigator.clipboard.writeText(value).then(() => {
      $(button).attr("title", success_message)
        .tooltip('_fixTitle')
        .tooltip('show')
        .attr("title", original_title)
        .tooltip('_fixTitle');
    },() => {
      $(button).attr("title", failure_message)
        .tooltip('_fixTitle')
        .tooltip('show')
        .attr("title", original_title)
        .tooltip('_fixTitle');
    });
  }

  connect() {
    $(this.element).tooltip({placement: "bottom"});
  }
}
