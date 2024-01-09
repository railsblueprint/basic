// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import 'jquery.global'
import * as bootstrap from "bootstrap"
import "@hotwired/turbo-rails";
import 'channels';
import "controllers";
import "trix";
import "@rails/actiontext";
import "keyboard-pagination"
import "select2"

// import "chartkick";
// import "Chart.bundle";

console.log("loaded application_admin")

$(function() {

  $("[data-bs-toggle=\"tooltip\"]").tooltip();

  // Needed to enable link inside button
  $(".action-edit-section").click((e) => {
    const target = e.currentTarget;
    Turbo.visit(target.href);
  })


  $(".needs-validation").each((index, form) => {
    form.addEventListener(
        "submit",
        function (event) {
          if (!form.checkValidity()) {
            event.preventDefault();
            event.stopPropagation();
          }

          form.classList.add("was-validated");
        },
        false
    );
  });

})
