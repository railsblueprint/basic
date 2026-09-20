import {Controller} from "@hotwired/stimulus"


import suneditor from 'suneditor'
import plugins from 'suneditor/plugins'

import CodeMirror from 'codemirror5';
import 'codemirror5/mode/htmlmixed';

export default class extends Controller {
    connect() {
        this.editor = suneditor.create(this.element, {
            externalLibs: {
                codeMirror: {src: CodeMirror}
            },
            plugins: plugins,
            buttonList: [
                ['undo', 'redo'],
                ['blockStyle'],
                ['paragraphStyle', 'blockquote'],
                ['bold', 'underline', 'italic', 'strike', 'subscript', 'superscript'],
                ['fontColor', 'backgroundColor', 'textStyle'],
                ['removeFormat'],
                ['outdent', 'indent'],
                ['align', 'hr', 'list', 'lineHeight'],
                ['table', 'link', 'image'],
                ['fullScreen', 'showBlocks', 'codeView'],
            ],
            height: '600px',
            events: {
                // Keep the underlying textarea current so a plain form submit carries the content.
                onChange: ({data}) => {
                    this.element.value = data;
                }
            }
        });

        if(this.element.disabled) {
            this.editor.$.ui.readOnly(true);
        }
    }

    disconnect() {
        this.editor?.destroy();
        this.editor = null;
    }
}
