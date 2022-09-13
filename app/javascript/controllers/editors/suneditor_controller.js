import {Controller} from "@hotwired/stimulus"


import suneditor from 'suneditor'
import plugins from 'suneditor/plugins'

import CodeMirror from 'codemirror5';
import 'codemirror5/mode/htmlmixed';

export default class extends Controller {
    connect() {
        this.editor = suneditor.create(this.element, {
            codeMirror: CodeMirror,
            plugins: plugins,
            buttonList: [
                ['undo', 'redo'],
                ['formatBlock'],
                ['paragraphStyle', 'blockquote'],
                ['bold', 'underline', 'italic', 'strike', 'subscript', 'superscript'],
                ['fontColor', 'hiliteColor', 'textStyle'],
                ['removeFormat'],
                ['outdent', 'indent'],
                ['align', 'horizontalRule', 'list', 'lineHeight'],
                ['table', 'link', 'image'],
                ['fullScreen', 'showBlocks', 'codeView'],
            ],
            height: 600
        });

        if(this.element.disabled) {
            this.editor.readOnly(true);
        }

        this.editor.onChange =  (contents, core) =>  {
            this.editor.save();
        }

    }
}
