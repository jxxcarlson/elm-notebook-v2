module View.CustomElement exposing (niceColor)

import Element exposing (Element)
import Html exposing (Attribute, Html, node)
import Html.Attributes exposing (attribute)


niceColor : String -> String -> Element msg
niceColor txt color =
    toElmUi <| niceColor_ txt color


niceColor_ : String -> String -> Html msg
niceColor_ txt color =
    node "nice-color-text"
        [ attribute "text" txt
        , attribute "color" color
        ]
        []


toElmUi : Html msg -> Element msg
toElmUi html =
    Element.html <| html
