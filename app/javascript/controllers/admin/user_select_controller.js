import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    const cssClass = this.element.classList.contains('form-control-sm') ? "select2--small" : "";
    const emptyText = this.element.dataset.empty;
    const processResults = (data, params) => {
      if (!emptyText || params._type == "query:append"){
        return data;
      }
      return {
        results: [{id: "", text: emptyText}, ...data.results],
        pagination: data.pagination
      };
    };

    $(this.element).select2({
      theme: "bootstrap-5",
      containerCssClass: cssClass, // For Select2 v4.0
      selectionCssClass: cssClass, // For Select2 v4.1
      dropdownCssClass: cssClass,
      ajax: {
        url: '/admin/users/lookup',
        dataType: 'json',
        processResults: processResults
      },

    });
  }
}
