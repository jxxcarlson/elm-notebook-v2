module View.Header exposing (view)

import Color
import Element as E exposing (Element)
import Element.Background as Background
import Element.Border
import Element.Font as Font
import Message
import Predicate
import Types exposing (AppMode(..))
import UILibrary.Color as Color
import View.Button as Button
import View.Color
import View.Geometry
import View.Input
import View.Style
import View.Utility


view model =
    case model.currentUser of
        Nothing ->
            notSignedInHeader model

        Just user ->
            signedInHeader model user


notSignedInHeader model =
    E.row
        [ E.spacing 24
        , Font.size 14
        , E.height (E.px View.Geometry.headerHeight)
        , E.paddingXY View.Geometry.hPadding 0
        , Background.color Color.darkerSteelGray
        , Element.Border.widthEach { left = 0, right = 0, top = 0, bottom = 1 }
        , Element.Border.color Color.stillDarkerSteelGray
        , E.width (E.px (View.Geometry.appWidth model))
        ]
        [ E.row
            [ E.spacing 12
            ]
            [ View.Input.username model
            , View.Input.password model
            , Button.signIn
            ]
        , welcomeLink
        , Button.manualLarge
        , E.el [ E.alignRight ] Button.signUp
        ]


welcomeLink =
    E.newTabLink []
        { url = "https://elm-notebook.lamdera.app/p/jxxcarlson-welcome-to-elm-notebooks"
        , label = E.el [ Font.underline, Font.color (E.rgb 0.65 0.65 1), Font.size 16 ] (E.text "Sign in as Guest")
        }


signedInHeader model user =
    E.row
        [ E.spacing 24
        , E.paddingXY View.Geometry.hPadding 0
        , E.spacing 24
        , E.height (E.px View.Geometry.headerHeight)
        , E.width (E.px <| View.Geometry.appWidth model)
        , Background.color Color.darkSteelGray
        , Element.Border.widthEach { left = 0, right = 0, top = 0, bottom = 1 }
        , Element.Border.color Color.stillDarkerSteelGray
        ]
        [ E.row [ E.spacing 8, E.paddingEach { left = 10, right = 0, top = 0, bottom = 0 } ]
            [ title "Elm Notebook:"
            , if model.appMode == AMEditTitle then
                View.Input.title model

              else
                underlinedTitle model.currentBook.title
            ]
        , View.Utility.showIf (Predicate.regularUser model) (Button.editTitle model.appMode)
        , View.Utility.showIf (Predicate.regularUser model) Button.newNotebook
        , View.Utility.showIf (Predicate.regularUser model) (Button.deleteNotebook model.deleteNotebookState)
        , View.Utility.showIf (Predicate.regularUser model) (Button.cancelDeleteNotebook model.deleteNotebookState)

        -- , Button.clearValues
        , welcomeLink
        , Button.manual
        , E.el [ E.alignRight ] (Button.signOut user.username)
        ]


title : String -> Element msg
title str =
    E.el [ Font.size 18, Font.color View.Color.white ] (E.text str)


underlinedTitle : String -> Element msg
underlinedTitle str =
    E.el [ Font.size 18, Font.color View.Color.white, Font.underline ] (E.text str)
