module View.Footer exposing (view)

import Config
import Element as E exposing (Element)
import Element.Font as Font
import Message
import Notebook.Types exposing (MessageItem(..))
import Predicate
import Types exposing (FrontendModel, FrontendMsg)
import UILibrary.Color as Color
import View.Button as Button
import View.Geometry
import View.MarkdownThemed
import View.Popup.Admin
import View.Popup.CLI
import View.Popup.Manual
import View.Popup.NewDataSet
import View.Popup.NewNotebook
import View.Popup.Packages
import View.Popup.SignUp
import View.Popup.StateEditor
import View.Popup.ViewPrivateDataSets
import View.Popup.ViewPublicDataSets
import View.Style
import View.Utility


view model =
    E.row
        [ E.height (E.px View.Geometry.footerHeight)
        , E.width (E.px <| View.Geometry.appWidth model)
        , Font.size 14
        , E.paddingEach { left = 18, right = 0, top = 0, bottom = 0 }
        , E.alignBottom
        , E.inFront (View.Popup.Admin.view model)
        , E.inFront (View.Popup.SignUp.view model)
        , E.inFront (View.Popup.NewNotebook.view model)
        , E.inFront (View.Popup.Manual.view model View.MarkdownThemed.lightTheme)
        , E.inFront (View.Popup.NewDataSet.view model)
        , E.inFront (View.Popup.ViewPublicDataSets.view model)
        , E.inFront (View.Popup.ViewPrivateDataSets.view model)
        , E.inFront (View.Popup.ViewPrivateDataSets.view model)
        , E.inFront (View.Popup.Packages.view model)
        , E.inFront (View.Popup.StateEditor.view model)
        , E.inFront (View.Popup.CLI.view model)
        , View.Style.bgGray 0.0
        , E.spacing 12
        , E.paddingXY 24 0
        ]
        (case model.currentUser of
            Nothing ->
                [ displayMessages model
                ]

            Just _ ->
                [ E.el [ Font.color (E.rgb 1 1 1) ] (E.text <| String.left 4 model.currentBook.id)
                , View.Utility.showIfIsAdmin model (Button.adminPopup model)
                , Button.packagesPopup model
                , errorIndicator model
                , displayMessages model
                , let
                    url =
                        Config.appUrl ++ "/open/" ++ model.currentBook.slug
                  in
                  Button.copyNotebookUrl url
                , E.newTabLink [ E.alignRight, Font.underline, Font.color (E.rgb 0.4 0.4 1) ]
                    { url = Config.appUrl ++ "/open/" ++ model.currentBook.slug
                    , label = E.text model.currentBook.slug
                    }
                , case model.currentBook.origin of
                    Just _ ->
                        E.el [ E.paddingEach { left = 24, right = 0, top = 0, bottom = 0 } ] Button.pullNotebook

                    Nothing ->
                        E.none
                , View.Utility.showIf (Predicate.canClone model) Button.cloneNotebook
                ]
        )


errorIndicator : { a | errorReports : List Notebook.Types.ErrorReport } -> Element FrontendMsg
errorIndicator model =
    E.el [ Font.color (E.rgb 1 0.5 0) ]
        (E.text <|
            String.fromInt (List.length model.errorReports)
                ++ " errors"
        )


displayMessages model =
    E.el
        [ E.width E.fill
        , E.height (E.px View.Geometry.footerHeight)
        , E.paddingXY View.Geometry.hPadding 4
        , View.Style.bgGray 0.1
        , E.centerY
        ]
        (Message.view 30 model)
