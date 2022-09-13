import {Controller} from "@hotwired/stimulus"

export default class extends Controller {
  connect(){
    $(this.element).on("click", ".nav-link:not(.nav-group)", () => {
      $("body").removeClass("sidebar-shown");
    });
  }

  disconnect(){
    $(this.element).off("click", ".nav-link:not(.nav-group)");
  }

  hide() {
    $("html").toggleClass("sidebar-hidden");
  }
  show() {
    $("body").toggleClass("sidebar-shown");
  }
  
  escape() {
    $("body").removeClass("sidebar-shown");
  }

}
