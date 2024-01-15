module View.Main exposing (view)

import Element as E exposing (Element)
import Element.Background as Background
import Element.Font as Font
import Html exposing (Html)
import Types exposing (FrontendModel, FrontendMsg)
import UILibrary.Color as Color
import View.Body
import View.BodyNotSignedIn
import View.Color
import View.Config
import View.Footer
import View.Geometry
import View.Header
import View.LHSidebar
import View.Style
import View.Utility


type alias Model =
    FrontendModel


view : Model -> Html FrontendMsg
view model =
    E.layoutWith { options = [ E.focusStyle View.Utility.noFocus ] }
        [ View.Style.bgGray 0.0, E.clipX, E.clipY, E.width (E.px <| model.windowWidth) ]
        (mainColumn model)


mainColumn : Model -> Element FrontendMsg
mainColumn model =
    E.column [ E.centerX, E.width (E.px <| model.windowWidth) ]
        [ View.Header.view model
        , E.row [ E.centerX, E.width E.fill ]
            [ View.LHSidebar.view model, body model ]
        , View.Footer.view model
        ]


body : Model -> Element FrontendMsg
body model =
    case model.currentUser of
        Nothing ->
            View.BodyNotSignedIn.view model

        Just user ->
            View.Body.view model user


title : String -> Element msg
title str =
    E.row [ E.centerX, View.Style.bgGray 0.9 ] [ E.text str ]
