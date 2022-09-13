import {Controller} from "@hotwired/stimulus"

export default class extends Controller {
  click(e) {
    const target = $(this.element)
    const confirmed = target.attr("data-confirmed");
    const modal = $('#dataConfirmModal');

    if (!modal[0]) {
      const result = confirm($(target).attr('data-confirm'));
      if (!result) {
        e.stopPropagation()
        e.preventDefault();
      }
      return;
    }

    console.log("confirmed", confirmed);

    if (!confirmed) {
      e.preventDefault();
      e.stopPropagation();
      modal.find('.modal-body').text($(target).attr('data-confirm'));
      modal.modal("show");
      modal.find(".action-confirm").off("click").click((e) => {
        target.attr("data-confirmed", "true");
        target[0].click();
        modal.modal("hide");
      })
    } else {
      target.removeAttr("data-confirmed");
      /* allow default behavior to happen */
    }
  }
}
