import {Controller} from "@hotwired/stimulus";
import Sortable from 'sortablejs';

export default class extends Controller {
  connect() {
    this.element.style.width = '100%';
    this.initSelect2();

    // Hotwire binding is not working for some reason, so using jquery
    if ($(this.element).data("autosubmit")) {
      $(this.element).on("change", () => {
        this.element.form.requestSubmit()
      })
    }
  }

  disconnect() {
    $(this.element).select2('destroy');
  }

  resize (){
    this.initSelect2();
  }

  initSelect2() {
    const sortable = $(this.element).data('sortable');

    const cssClass = (this.element.classList.contains('form-control-sm') ? "select2--small" : "") +
      (sortable ? " select2--sortable " : "");

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

    const ajax =  this.element.dataset.source ? {
      url: '/admin/users/lookup',
          dataType: 'json',
          processResults: processResults
    } : null;


    function formatSortable (item) {
      if (!item.id || !sortable) {
        return item.text;
      }
      return $(`<span><span class="sortable-option" data-option-value="${item.id}">${item.text}</span> <i class="bi bi-arrows-move ps-2"></i></span>`);
    };


    $(this.element).select2({
      width: 'resolve',
      theme: "bootstrap-5",
      containerCssClass: cssClass, // For Select2 v4.0
      selectionCssClass: cssClass, // For Select2 v4.1
      dropdownCssClass: cssClass,
      templateSelection: formatSortable,
      ajax: ajax
    })

    if( sortable) {
      $(this.element).on('select2:select', function (e) {
        var id = e.params.data.id;
        var option = $(e.target).children('[value=' + id + ']');
        option.detach();
        $(e.target).append(option).change();
      });

      const select2 = $(this.element).data('select2');

      Sortable.create(select2.$selection.find(".select2-selection__rendered")[0], {
        animation: 150,
        onEnd: () => {
          select2.$selection.find(".select2-selection__choice").each((index, elem) => {
            const value = $(elem).find(".sortable-option").data("option-value")
            const option = $(this.element).children('[value=' + value + ']');
            option.detach();
            $(this.element).append(option).change();
          })
        }
      });
    }

  }
}
