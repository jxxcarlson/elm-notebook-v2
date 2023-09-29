module View.Style exposing
    ( bgGray
    , buttonStyle
    , fgGray
    , monospace
    )

import Element exposing (Element)
import Element.Background as Background
import Element.Font as Font


monospace =
    Font.family
        [ Font.typeface "Inconsolata"
        , Font.monospace
        ]


fgGray : Float -> Element.Attr decorative msg
fgGray g =
    Font.color (Element.rgb g g g)


bgGray : Float -> Element.Attr decorative msg
bgGray g =
    Background.color (Element.rgb g g g)


buttonStyle : List (Element.Attr () msg)
buttonStyle =
    [ Font.color (Element.rgb255 255 255 255)
    , Element.paddingXY 15 8
    ]
