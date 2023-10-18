module View.Popup.CLI exposing (..)

import Element as E exposing (Element)
import Element.Background as Background
import Element.Font as Font
import Types
import UILibrary.Color
import View.Button
import View.Geometry
import View.Input
import View.Utility


view : Types.FrontendModel -> Element Types.FrontendMsg
view model =
    case model.popupState of
        Types.CLIPopup ->
            E.column
                [ E.height (E.px 200)
                , E.width (E.px 580)
                , E.moveUp (toFloat <| View.Geometry.bodyHeight model)
                , E.moveRight 400
                , Background.color UILibrary.Color.stillDarkerSteelGray
                , E.padding 24
                , E.spacing 24
                ]
                [ E.el
                    [ Font.color UILibrary.Color.white
                    , Font.size 18
                    , E.paddingEach { top = 0, bottom = 0, left = 0, right = 0 }
                    ]
                    (E.text "CLI")
                , View.Input.command model
                , E.row [ E.spacing 24 ] [ View.Button.runCommand, View.Button.dismissPopup ]
                ]

        _ ->
            E.none
