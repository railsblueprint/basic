import 'jquery.global'
import * as bootstrap from "bootstrap"
import "@hotwired/turbo-rails";
import 'channels';
import "controllers";
import "trix";
import "@rails/actiontext";

$(function() {
  $("[data-bs-toggle=\"tooltip\"]").tooltip();

  $(".alert").alert();
})
