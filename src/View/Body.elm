module View.Body exposing (view)

import Dict exposing (Dict)
import Element as E exposing (Element)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Notebook.Book exposing (Book)
import Notebook.Cell exposing (Cell)
import Notebook.ErrorReporter exposing (RenderedErrorReport)
import Notebook.Eval
import Notebook.Types exposing (ErrorReport)
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
            , declarationsOrErrorReport model
            ]
        ]


declarationsOrErrorReport : FrontendModel -> Element FrontendMsg
declarationsOrErrorReport model =
    if model.errorReports == [] then
        declarations model

    else if model.showErrorPanel then
        reportErrors model model.currentBook.cells (model.errorReports |> List.map Notebook.ErrorReporter.renderReport)

    else
        declarations model



-- REPORT_ERRORS


reportErrors : FrontendModel -> List Notebook.Cell.Cell -> List RenderedErrorReport -> Element FrontendMsg
reportErrors model cells errorSummary =
    let
        errorKeys_ =
            Notebook.ErrorReporter.errorKeysFromCells cells
    in
    errorReporterStyle model
        ([ View.Button.toggleShowErrorPanel model
         , errorSummaryHeading model errorKeys_
         , importPackageWarning model
         , makeErrorKeys errorKeys_
         ]
            ++ errorDetails model errorSummary
        )



-- HELPERS FOR REPORT_ERRORS


errorReporterStyle model =
    E.column
        [ Font.size 14
        , E.spacing 0
        , E.width (E.px <| View.Geometry.sidePanelWidth model)
        , Border.widthEach { left = 2, right = 0, top = 0, bottom = 0 }
        , Border.color (E.rgb255 73 78 89)
        , Background.color (E.rgb 0 0 0)
        , View.Style.monospace
        , E.paddingEach
            { top = 18, bottom = 36, left = 0, right = 0 }
        ]


errorDetails : FrontendModel -> List RenderedErrorReport -> List (Element FrontendMsg)
errorDetails model listOfRenderedErrorReports =
    [ E.el
        [ Font.color reportLabelColor
        , Font.size 16
        , E.paddingEach { left = 12, right = 0, top = 18, bottom = 12 }
        ]
        (E.text ("Details: " ++ String.fromInt (List.length listOfRenderedErrorReports)))
    , E.column
        [ E.height (E.px <| View.Geometry.loweRightSidePanelHeight model)
        , E.width (E.px <| View.Geometry.sidePanelWidth model)
        , E.scrollbarY
        ]
        (List.indexedMap
            (\k ( cIndex, report ) ->
                E.column
                    [ if k == 0 then
                        E.paddingEach { left = 0, top = 36, bottom = 0, right = 0 }

                      else
                        E.paddingEach { left = 0, top = 12, bottom = 0, right = 0 }
                    ]
                    [ E.column [ Font.color reportLabelColor, Font.size 14, E.paddingEach { left = 12, top = 12, bottom = 4, right = 0 } ]
                        [ E.text <| "Cell: " ++ (String.fromInt (cIndex + 1) ++ ".")
                        , E.text "______________________"
                        ]
                    , E.column
                        [ E.paddingXY 12 12
                        , E.spacing 12
                        , View.Style.monospace
                        , E.width (E.px 500)
                        ]
                        report
                    ]
            )
            listOfRenderedErrorReports
        )
    ]


makeErrorKeys : List ( List Int, String ) -> Element msg
makeErrorKeys errorKeys_ =
    E.column
        [ E.spacing 24
        , E.paddingEach { left = 12, right = 12, top = 12, bottom = 24 }
        , E.height (E.px 200)
        , E.scrollbarY
        ]
        (List.map (\( loc, s ) -> E.paragraph [ E.spacing 8 ] [ displayLocation loc, E.text s ]) errorKeys_)


reportLabelColor =
    E.rgb 1 0.5 0



-- errorSummaryHeading : { a | windowWidth : Int } -> List b -> Element msg


errorSummaryHeading model errorKeys_ =
    E.row
        [ E.paddingXY 18 0
        , E.paddingXY 12 24
        , E.spacing 8
        , E.width (E.px <| View.Geometry.sidePanelWidth model)
        ]
        [ E.el
            [ Font.size 18
            , Font.color reportLabelColor
            ]
            (E.text <| "Error summary: " ++ String.fromInt (List.length errorKeys_))
        ]


importPackageWarning : FrontendModel -> Element msg
importPackageWarning model =
    if String.contains "You are trying to import" (Notebook.ErrorReporter.errorsToString model.currentBook.cells) then
        E.paragraph
            [ Font.size 14
            , Font.color (E.rgb 1 1 0)
            , E.paddingXY 12 12
            ]
            [ E.text "You are trying to import a package that is not installed. "
            , E.text "Please click on the \"Install Packages\" button & install the missing package(s). "
            , E.text
                "Then click on \"Clear Values\" or \"Run all Cells\""
            ]

    else
        E.none


displayLocation : List Int -> Element msg
displayLocation ks =
    ks |> List.map ((\k -> k + 1) >> String.fromInt) |> String.join " " |> (\s -> E.el [ Font.color reportLabelColor ] (E.text <| "Cell " ++ s ++ ": "))



-- END OF HELPERS FOR REPORT_ERRORS


declarations : FrontendModel -> Element FrontendMsg
declarations model =
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
            [ E.el [ Font.underline ] (E.text <| "Types and Declarations")
            , E.el [] (E.text <| "(" ++ String.fromInt (Dict.size model.evalState.decls + Dict.size model.evalState.types) ++ ")")
            , E.el [ E.paddingEach { left = 3, right = 0, top = 0, bottom = 0 } ] View.Button.updateDeclarationsDictionary
            , View.Button.toggleShowErrorPanel model
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
        --:: List.map (viewNotebookEntry model.currentBook) (List.sortBy (\b -> b.title) model.books)
        :: List.map (viewNotebookEntry model.currentBook) (List.sortBy bookSorter model.books)


bookSorter : Book -> ( Int, String )
bookSorter book =
    if book.title == "Welcome" then
        ( 0, "Welcome" )

    else
        ( 1, book.title )


publicBookSorter : Book -> ( Int, String )
publicBookSorter book =
    if book.title == "Welcome" then
        ( 0, "Welcome" )

    else
        ( 1, book.author ++ book.title )


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
        :: List.map (viewPublicNotebookEntry model.currentBook)
            (List.sortBy publicBookSorter
                (List.filter (\b -> b.public) model.books)
            )


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
            , theme = model.theme
            , pressedKeys = model.pressedKeys
            }
    in
    E.column
        [ E.paddingEach { left = 24, right = 0, top = 0, bottom = 0 }
        ]
        [ E.column
            [ View.Style.fgGray 0.6
            , Font.size 14
            , Background.color (E.rgb255 70 70 100)
            , E.height (E.px (View.Geometry.bodyHeight model))
            , E.width (E.px (View.Geometry.notebookWidth model - 20))
            , E.scrollbarY
            , E.clipX
            ]
            (List.map
                (Notebook.View.view viewData model.cellContent)
                model.currentBook.cells
            )
        ]
