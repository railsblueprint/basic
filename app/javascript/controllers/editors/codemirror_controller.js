import { Controller } from "@hotwired/stimulus";

import {basicSetup} from "codemirror";
import {EditorView, keymap} from "@codemirror/view"
import {defaultKeymap} from "@codemirror/commands"
import {html} from "@codemirror/lang-html"

export default class extends Controller {

  editorFromTextArea(textarea, extensions) {
    let view = new EditorView({doc: textarea.value, extensions})
    textarea.parentNode.insertBefore(view.dom, textarea);
    textarea.style.display = "none"
    if (textarea.form) textarea.form.addEventListener("submit", () => {
      textarea.value = view.state.doc.toString()
    })
  }

  connect() {
    this.editorFromTextArea(this.element, [html(), basicSetup, keymap.of(defaultKeymap)])
  }

  disconnect() {
  }
}
