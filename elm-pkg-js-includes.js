import * as evalJs from './elm-pkg-js/eval-js';
import * as testPorts from './elm-pkg-js/test-ports';
import * as coloredText from './elm-pkg-js/colored-text';
import * as evalJsToHtml from './elm-pkg-js/eval-js-to-html';

exports.init = async function init(app) {
  // @WARNING: this only runs for Lamdera production deploys!
  // This file will not run in Local development, an equivalent to this is
  // automatically generated in Local Development for every file in elm-pkg-js/

  evalJs.init(app)
  testPorts.init(app)
  coloredText.init(app)
  evalJsToHtml.init(app)
}
