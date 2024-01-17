
// https://blog.datacamp.engineering/codemirror-6-getting-started-7fd08f467ed2
// BRACKETS: https://stackoverflow.com/questions/70758962/how-to-configure-custom-brackets-for-markdown-for-codemirror-closebrackets
// BRACKETS: https://bl.ocks.org/curran/d8de41605fa68b627defa9906183b92f

import {EditorState,basicSetup} from "@codemirror/basic-setup"
import {EditorView, keymap} from "@codemirror/view"
// import {search} from "@codemirror/search"
import {indentWithTab} from "@codemirror/commands"
import {javascript} from "@codemirror/lang-javascript"
import {bracketMatching} from "@codemirror/matchbrackets"
import {closeBrackets} from "@codemirror/closebrackets"


let myTheme = EditorView.theme({

    "&": {
        color: "#ddd",
        backgroundColor: "#303040" //"#2a2b33"
    },

    // "&.cm-editor": {
    //     backgroundColor: "#303040" //"#2a2b33"
    // },

    // "&.cm-selectionBackground, .cm-selectionBackground ::selection": {
    //     backgroundColor: "#0e9"
    //   },

    "&.cm-highlight": {

        backgroundColor: "#a6a"
    },

    "&.cm-content": {
        caretColor: "#0e9",
        backgroundColor: "#a6a"
    },
    "&.cm-focused .cm-cursor": {
        borderLeftColor: "#0e9",
        borderLeft: "solid 8px",
        highlightColor: "#037ffc"
    },
    "&.cm-focused .cm-selectionBackground, ::selection": {
        backgroundColor: "#e74",
        color: "#fff"
    },
    "&.cm-gutters": {
        backgroundColor: "#045",
        color: "#ddd",
        border: "none"
    },
    "&.cm-bracket": { color: "#f00" },  // not working // "#f70a0a"
    ".cm-activeLine": { backgroundColor: "#008c8c"},
    "&.cm-selected": { backgroundColor: "#f00"},

}, {dark: true})



function editTransaction(editor, editEvent) {
    var event = editEvent
    console.log("!!!@@ editTransaction, EVENT", event)

        switch (event.op) {

               case "insert":
                   (editTransactionForInsert(editor, event.cursor, event.strval))
                   break;

               case "movecursor":
                   (editTransactionForMoveCursor(editor, event.cursor, event.intval))
                   break;

               case "delete":
                    (editTransactionForDelete(editor, event.cursor, event.intval))
                    break;

               case "noop":
                    (editTransactionForNoOp(editor, event.cursor))
                     break;
        }



//    var pos = editor.state.selection.main.head
//    console.log("!!! editTransaction, position", pos)

    // var op = editEvent.ops[0]



}

function editTransactionForInsert(editor, cursor, str) {
   console.log("T.Insert (cursor, str)", cursor, str)
   editor.dispatch({ changes: {from: cursor, insert: str}})
  }

function editTransactionForMoveCursor(editor, cursor) {
    console.log("T.movecursor (cursor)", cursor)
    editor.dispatch({ changes: {from: cursor, insert: ""}})
}

function editTransactionForDelete(editor, cursor, k) {
   console.log("T.delete (cursor, k)", k)
   editor.dispatch({ changes: {from: cursor, to: cursor + k, insert: ""}})
}

function editTransactionForNoOp(editor, cursor) {
    console.log("T.noOp (cursor)", cursor)
    editor.dispatch({ changes: {from: cursor, insert: ""}})
}

class CodemirrorEditor extends HTMLElement {

    static get observedAttributes() { return ['editcommand','selection', 'editordata', 'text']; }

    constructor(self) {

        self = super(self)
        console.log("CM EDITOR: In constructor")

        return self
    }

    connectedCallback() {

        console.log("CM EDITOR: In connectedCallback")

        let editorNode = document.querySelector('#editor-here');


            function sendText(editor) {
                const event = new CustomEvent('text-change',
                   { 'detail': {position: editor.state.selection.main.head, source: editor.state.doc.toString()}
                   , 'bubbles':true, 'composed': true});
                editor.dom.dispatchEvent(event);
             }

            function sendCursor(editor, position) {
                            const event = new CustomEvent('cursor-change',
                               { 'detail': {position: position, source:  editor.state.doc.toString()}
                               , 'bubbles':true, 'composed': true});
                            editor.dom.dispatchEvent(event);
                         }

            let panelTheme = EditorView.theme({
                                '&': { maxHeight: '100%' },
                                '.cm-gutter,.cm-content': { minHeight: '100px' },
                                '.cm-scroller': { overflow: 'auto' },
                              })

           // Set up editor if need be and point this.editor to it
            if (this.editor) {
                    editor = this.editor
                } else {
                    const options = {}
                    let editor = new EditorView({
                               state: EditorState.create({
                                 extensions: [basicSetup
                                   , myTheme
                                   // , EditorView.search({top: true})
                                   // should use this: -> // , search({top: true})
                                   , panelTheme
                                   , EditorView.lineWrapping
                                   , keymap.of([indentWithTab])
                                   //, bracketMatching({brackets: ["(", "[", "{"]})
                                   //, bracketMatching({brackets: ["(", ")", "[","]", "{","}", "<", ">"]})
                                   , closeBrackets()
                                   // Below: send updated text from CM to Elm
                                   , EditorView.updateListener.of((v)=> {
                                       if(v.docChanged) {
                                           sendText(editor)
                                       }
                                     })
                                   ]
                               , doc: ""
                               }),
                               parent: document.getElementById("editor-here")

                             })

                    editorNode.onclick = (event) =>
                         {  sendCursor(editor, (editor.posAtCoords({x: event.clientX, y: event.clientY}))) };

                    this.dispatchEvent(new CustomEvent("editor-ready", { bubbles: true, composed: true, detail: editor }))
                    this.editor = editor
                    this.editor.lastLineNumberFromClick = 0;
                    // this.editor.focus = editorFocus

                }
    }

    // Handle communication with Elm
    attributeChangedCallback(attr, oldVal, newVal) {

             function sendSelectedText(editor, str) {
                         console.log("sendSelectedText (dispatch)", str)
                         const event = new CustomEvent('selected-text', { 'detail': str , 'bubbles':true, 'composed': true});
                         editor.dom.dispatchEvent(event);
                      }

             function setEditorText(editor, str) {
                 if (str == "") {
                      console.log("ERROR?? -- setEditorText (dispatch) - empty string")
                 } else {
                     console.log("replaceAllText (dispatch)")
                     const currentValue = editor.state.doc.toString();
                     const endPosition = currentValue.length;

                     editor.dispatch({
                         changes: {
                             from: 0,
                             to: endPosition,
                             insert: str
                         }
                     })
                 }
             }

            function attributeChangedCallback_(editor, attr, oldVal, newVal) {
               switch (attr) {

                  case "editcommand":
                        console.log("!!!@ IN EDIT COMMAND !")
                        var editEvent = JSON.parse(newVal)

                        console.log("editor event!!!",editEvent)
                        editTransaction(editor, editEvent)
                        break

                  case "editordata":
                      // receive info from Elm (see Main.editor_)
                      var  data = JSON.parse(newVal)

                      // scroll the editor to the given line
                       var lineNumber = data.begin
                       var loc =  editor.state.doc.line(lineNumber);
                       var lastLineNumber = editor.state.doc.lines;


                       // offsetLineNumber: scroll to this line
                       var offsetLineNumber = lineNumber
                       if (lineNumber > 26)
                         { if (lineNumber > editor.lastLineNumberFromClick)
                             { offsetLineNumber = offsetLineNumber + 10}
                           else
                             { offsetLineNumber = offsetLineNumber - 10}
                          }
                       editor.lastLineNumberFromClick = lineNumber
                       if (offsetLineNumber > lastLineNumber) {offsetLineNumber = lastLineNumber}
                      // console.log("EDITOR_DATA: from = ", lineNumber, "to = ", offsetLineNumber);

                       var offsetLoc = editor.state.doc.line(offsetLineNumber);

                        // set up selection from first to last line of block
                        let loc2 = editor.state.doc.line(data.end);
                        let sel = {anchor : parseInt(loc.from), head : parseInt(loc2.to) }
                        console.log("EDITOR_DATA = ",  sel);
                        editor.dispatch({selection: sel});
                        editor.scrollPosIntoView(offsetLoc.from);
                  break

                  case "text":
                        // receive info from Elm (see Main.editor_):
                        // replace editor text with what was sent from Elm
                        console.log ("Attr case text: set the editor text to the string sent from Elm")
                        setEditorText(editor, newVal)
                        break

                  case "selection":
                       // receive info from Elm (see Main.editor_):
                       // ask for the current selection to be sent to Elm for LR sync
                       var selectionFrom = editor.state.selection.ranges[0].from
                       var selectionTo = editor.state.selection.ranges[0].to
                       var selectionSlice = editor.state.sliceDoc(selectionFrom,selectionTo )
                       console.log("Attr case selection", selectionSlice)
                       sendSelectedText(editor, selectionSlice)


                      break
             }
         } // end attributeChangedCallback_

         if (this.editor) { attributeChangedCallback_(this.editor, attr, oldVal, newVal)  }
         else { console.log("attr text", "this.editor not defined")}

         } // end attributeChangedCallback

  }

customElements.define("codemirror-editor", CodemirrorEditor); // (2)


