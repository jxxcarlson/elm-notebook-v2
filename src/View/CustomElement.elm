module View.CustomElement exposing (coloredText, renderJavascript)

import Element exposing (Element)
import Html exposing (Attribute, Html, node)
import Html.Attributes exposing (attribute)


coloredText : String -> String -> Element msg
coloredText txt color =
    toElmUi <| niceColor_ txt color


niceColor_ : String -> String -> Html msg
niceColor_ txt color =
    node "nice-color-text"
        [ attribute "text" txt
        , attribute "color" color
        ]
        []


renderJavascript : String -> Element msg
renderJavascript txt =
    let
        _ =
            Debug.log "@!@   Custom element here" "Rendering Javascript"
    in
    toElmUi <| renderJavascript_ txt


renderJavascript_ : String -> Html msg
renderJavascript_ txt =
    node "eval-js-to-html"
        [ attribute "sourceText" txt
        ]
        []


toElmUi : Html msg -> Element msg
toElmUi html =
    Element.html <| html
