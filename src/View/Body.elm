module View.Body exposing (view)

import Dict exposing (Dict)
import Element as E exposing (Element)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Notebook.Book exposing (Book)
import Notebook.Eval
import Notebook.View
import Types exposing (FrontendModel, FrontendMsg)
import UILibrary.Color as Color
import User
import Util
import View.Button
import View.Geometry
import View.Style


view : FrontendModel -> User.User -> Element FrontendMsg
view model user =
    E.row
        [ E.width (E.px (View.Geometry.appWidth model))
        , E.height (E.px (View.Geometry.bodyHeight model))
        ]
        [ viewNotebook model
        , E.column
            [ E.height (E.px (View.Geometry.bodyHeight model))
            , Font.color (E.rgb 0.9 0.9 0.9)
            , E.width E.fill
            ]
            [ viewNotebookList model user
            , declarations model user
            ]
        ]


declarations model user =
    E.column
        [ Font.size 14
        , E.spacing 18
        , E.width (E.px <| View.Geometry.sidePanelWidth model)
        , Border.widthEach { left = 2, right = 0, top = 0, bottom = 0 }
        , Border.color (E.rgb255 73 78 89)
        , View.Style.monospace
        , E.paddingEach
            { top = 18, bottom = 36, left = 0, right = 0 }
        ]
        [ E.row [ E.paddingXY 18 0, E.spacing 8, E.width (E.px <| View.Geometry.sidePanelWidth model) ]
            [ E.el [ Font.underline ] (E.text <| "Declarations")
            , E.el [] (E.text <| "(" ++ String.fromInt (Dict.size model.evalState.decls) ++ ")")
            , E.el [ E.paddingEach { left = 3, right = 0, top = 0, bottom = 0 } ] View.Button.updateDeclarationsDictionary
            ]
        , E.el
            [ E.height (E.px <| View.Geometry.loweRightSidePanelHeight model)
            , E.width (E.px <| View.Geometry.sidePanelWidth model)
            , E.scrollbarY
            ]
            (Notebook.Eval.displayDictionary (Util.mergeDictionaries model.evalState.types model.evalState.decls))
        ]


monitor : FrontendModel -> Element FrontendMsg
monitor model =
    E.column
        [ E.paddingEach { left = 0, right = 24, top = 0, bottom = 0 }
        , E.spacing 18
        , Font.size 14
        , E.height (E.px monitorHeight)
        , Border.widthEach { left = 1, right = 0, top = 0, bottom = 0 }
        , Border.color Color.darkGray
        , E.scrollbarY
        , Font.color Color.white
        ]
        []


kVDictToString : Dict String String -> String
kVDictToString dict =
    Dict.foldl (\k v acc -> acc ++ k ++ ": " ++ v ++ "\n") "" dict


monitorHeight =
    360


viewNotebookList : FrontendModel -> User.User -> Element FrontendMsg
viewNotebookList model user =
    E.column
        [ E.spacing 1
        , E.alignTop
        , Font.size 14
        , E.width (E.px (View.Geometry.sidePanelWidth model - 24))
        , Border.widthEach { left = 1, right = 0, top = 0, bottom = 1 }
        , Border.color (E.rgb 0.4 0.4 0.5)
        , Background.color (E.rgb255 73 78 89)
        , E.height (E.px (View.Geometry.bodyHeight model - View.Geometry.loweRightSidePanelHeight model))
        , E.scrollbarY
        , E.paddingXY 18 12
        ]
        (case model.showNotebooks of
            Types.ShowUserNotebooks ->
                viewMyNotebookList model user

            Types.ShowPublicNotebooks ->
                viewPublicNotebookList model user
        )


notebookControls : FrontendModel -> Element FrontendMsg
notebookControls model =
    E.row [ E.spacing 12, E.paddingEach { top = 0, bottom = 12, left = 0, right = 0 } ]
        [ View.Button.stateEditor
        , View.Button.resetClock
        , View.Button.setClock model
        ]


viewMyNotebookList : FrontendModel -> User.User -> List (Element FrontendMsg)
viewMyNotebookList model user =
    E.el [ Font.color Color.white, E.paddingEach { left = 0, right = 0, bottom = 8, top = 0 } ]
        (E.text <| "Notebooks: " ++ String.fromInt (List.length model.books))
        :: controls model.showNotebooks
        :: List.map (viewNotebookEntry model.currentBook) (List.sortBy (\b -> b.title) model.books)


viewNotebookEntry : Book -> Book -> Element FrontendMsg
viewNotebookEntry currentBook book =
    E.row []
        [ View.Button.viewNotebookEntry currentBook book
        , case book.origin of
            Nothing ->
                E.none

            Just origin ->
                case Util.firstPart origin of
                    Nothing ->
                        E.none

                    Just username ->
                        E.el [ Font.color Color.lightGray, E.paddingXY 0 8, E.width (E.px 80) ] (E.text <| " (" ++ username ++ ")")
        ]


viewPublicNotebookList model user =
    E.el [ Font.color Color.white, E.paddingEach { left = 0, right = 0, bottom = 8, top = 0 } ]
        (E.text <| "Notebooks: " ++ String.fromInt (List.length model.books))
        :: controls model.showNotebooks
        :: List.map (viewPublicNotebookEntry model.currentBook) (List.sortBy (\b -> b.author ++ b.title) model.books)


viewPublicNotebookEntry : Book -> Book -> Element FrontendMsg
viewPublicNotebookEntry currentBook book =
    E.row []
        [ E.el [ Font.color Color.lightGray, E.paddingXY 0 8, E.width (E.px 80) ] (E.text book.author)
        , View.Button.viewNotebookEntry currentBook book
        ]


controls : Types.ShowNotebooks -> Element FrontendMsg
controls showNotebooks =
    E.row [ E.spacing 12 ]
        [ View.Button.myNotebooks showNotebooks
        , E.el [ E.paddingXY 0 8 ] (View.Button.publicNotebooks showNotebooks)
        ]


viewNotebook : FrontendModel -> Element FrontendMsg
viewNotebook model =
    let
        viewData =
            { book = model.currentBook
            , kvDict = model.kvDict
            , width = View.Geometry.notebookWidth model
            , ticks = model.tickCount
            , cellDirection = model.cellInsertionDirection
            , errorOffset = Notebook.Eval.replErrorOffset model.evalState.decls
            }
    in
    E.column
        [ E.paddingEach { left = 24, right = 0, top = 0, bottom = 0 }
        ]
        [ E.column
            [ View.Style.fgGray 0.6
            , Font.size 14
            , E.height (E.px (View.Geometry.bodyHeight model))
            , E.width (E.px (View.Geometry.notebookWidth model))
            , E.scrollbarY
            , E.clipX
            ]
            (List.map
                (Notebook.View.view viewData model.cellContent)
                model.currentBook.cells
            )
        ]
