exports.init = async function(app) {

    console.log("Loading colored-text.js")

    // Define the new element
    class NiceColorText extends HTMLElement {
      // Called when element is inserted in DOM
      connectedCallback() {
        const text = this.getAttribute('text') || 'Default Text';
        const color = this.getAttribute('color') || 'blue';

        this.style.color = color;
        this.innerHTML = `<p>${text}</p>`;
      }
    }

    // Register the new element with the browser
    customElements.define('nice-color-text', NiceColorText);

}