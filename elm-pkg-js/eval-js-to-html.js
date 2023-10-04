exports.init = async function(app) {

    console.log("Loading eval-js-html.js")

    // Define the new element
    class EvalJsToHtml extends HTMLElement {
      // Called when element is inserted in DOM
      connectedCallback() {

        console.log("@!@!eval-js-to-html connectedCallback")

        // Get the JS sourceText attribute or use a default value
        // const text = this.getAttribute('sourceText') || 'console.log("No sourceText attribute")';
        const text = this.getAttribute('sourceText') || 'no-go';



        if (window.Worker && text != 'no-go') {

              console.log("@!@!eval-js-to-html window.Worker")

              console.log("@!@!text", text)

              // Create a Blob from the JavaScript code (string) and create a URL for it
              var blob = new Blob([text.replace('_Debug_toAnsiString(true,','_Debug_toAnsiString(false,' )], { type: 'application/javascript' });
              var url = URL.createObjectURL(blob);

              // Instantiate a new Web Worker object with the blob URL
              const myWorker = new Worker(url);

              // Define an onmessage handler to receive messages from the worker
              myWorker.onmessage = (e) => {
                  console.log('@!@!FROM WORKER', e.data);
                  this.innerHTML = `<p>${e.data}</p>`
              };

              // Define an onerror handler to catch errors from the worker
              myWorker.onerror = (e) => {
                  console.error('@!@!Error from worker:', e.message);
                  this.innerHTML = `<p>Error from Worker</p>`
              };
          } // end if
           else {
              console.error('@!@!Web Worker is not supported in your browser.');
              this.innerHTML = `<p>Web Worker is not supported in your browser.</p>`
          } // end else

      } // end connectedCallback
    } // end class EvalJsToHtml

    // Register the new element with the browser
    customElements.define('eval-js-to-html', EvalJsToHtml )

}
