module Notebook.View exposing (view)

import Element as E exposing (Element)
import Element.Background as Background
import Element.Border
import Element.Events
import Element.Font as Font
import Element.Input
import Html.Attributes as HA
import List.Extra
import Notebook.Book exposing (ViewData)
import Notebook.Cell exposing (Cell, CellState(..), CellType(..), CellValue(..))
import Notebook.ErrorReporter
import Notebook.Parser
import Notebook.Types
import Notebook.Utility as Utility
import Types exposing (FrontendModel, FrontendMsg(..))
import UILibrary.Button as Button
import UILibrary.Color as Color
import View.Button exposing (runCell)
import View.CellThemed
import View.Style
import View.Utility


view : ViewData -> String -> Cell -> Element FrontendMsg
view viewData cellContents cell =
    E.column
        [ E.paddingEach { top = 0, right = 0, bottom = 0, left = 0 }
        , E.width (E.px viewData.width)
        , Background.color (E.rgb255 99 106 122)
        ]
        [ E.row
            [ E.width (E.px viewData.width) ]
            [ viewSourceAndValue viewData cellContents cell
            ]
        ]


viewSourceAndValue : ViewData -> String -> Cell -> Element FrontendMsg
viewSourceAndValue originalviewData cellContents cell =
    let
        style =
            case ( cell.cellState, cell.tipe ) of
                ( CSEdit, _ ) ->
                    [ Element.Border.color (E.rgb 0.75 0.75 0.75)
                    , editBGColor
                    , Element.Border.widthEach
                        { bottom = 1
                        , left = 0
                        , right = 0
                        , top = 1
                        }
                    ]

                ( CSView, CTCode ) ->
                    [ Element.Border.color (E.rgb 0 0 1.0)
                    , Element.Border.widthEach
                        { bottom = 1
                        , left = 0
                        , right = 0
                        , top = 1
                        }
                    ]

                ( CSView, CTMarkdown ) ->
                    [ Element.Border.color (E.rgb 0.75 0.75 0.75)
                    , Element.Border.widthEach
                        { bottom = 0
                        , left = 0
                        , right = 0
                        , top = 1
                        }
                    ]

        viewData =
            { originalviewData | width = originalviewData.width - 24 }
    in
    E.column ([ Background.color (Utility.cellColor cell.tipe), E.paddingXY 6 12, E.spacing 4 ] ++ style)
        [ E.el [ E.alignRight, Background.color (Utility.cellColor cell.tipe) ] (controls viewData cell)
        , viewSource (viewData.width - controlWidth) cell cellContents
        , E.el (hrule cell) (viewValue viewData cell)
        ]


hrule cell =
    case cell.tipe of
        CTCode ->
            [ Element.Border.widthEach { top = 2, bottom = 0, left = 0, right = 0 }
            , Element.Border.color (E.rgba 0.75 0.75 1.0 0.8)
            ]

        CTMarkdown ->
            []


controlBGEdit =
    Background.color (E.rgb 0.8 0.8 1.0)


bgColor cell =
    Background.color (Utility.cellColor cell.tipe)


controls viewData cell =
    case cell.cellState of
        CSView ->
            E.none

        CSEdit ->
            E.row
                [ controlBGEdit
                , E.width (E.px (viewData.width - 3))
                , E.centerX
                , E.paddingEach { left = 0, right = 12, bottom = 0, top = 0 }
                , bgColor cell
                ]
                [ E.row
                    [ E.spacing 2
                    , E.alignLeft
                    , E.height (E.px 32)
                    , E.spacing 24
                    , E.paddingEach { top = 2, bottom = 2, left = 8, right = 4 }
                    ]
                    [ E.row [ E.spacing 6 ]
                        [ newCellAboveOrBelow viewData.cellDirection
                        , newCodeCellAt cell.cellState cell.index
                        , newMarkdownCellAt cell.cellState cell.index
                        ]
                    , E.row [ E.spacing 6 ]
                        [ runCell CSEdit cell.tipe cell.index
                        , runCell CSView cell.tipe cell.index
                        ]
                    ]
                , E.row
                    [ E.spacing 6
                    , E.alignRight
                    , E.height (E.px 32)
                    , E.paddingEach { top = 2, bottom = 2, left = 8, right = 4 }
                    ]
                    [ deleteCellAt cell.cellState cell.index
                    , clearCellAt cell.cellState cell.index
                    , View.Button.lockCell cell
                    , viewIndex cell
                    ]
                ]


controlWidth =
    0


viewSource : Int -> Cell -> String -> Element FrontendMsg
viewSource width cell cellContent =
    case cell.cellState of
        CSView ->
            case cell.tipe of
                CTCode ->
                    renderCode cell width

                CTMarkdown ->
                    renderMarkdown cell width

        CSEdit ->
            editCell width cell cellContent


viewValue : ViewData -> Cell -> Element FrontendMsg
viewValue viewData cell =
    case cell.tipe of
        CTMarkdown ->
            E.none

        CTCode ->
            case cell.report of
                Just report ->
                    viewFailure viewData report

                Nothing ->
                    viewSuccess viewData cell


viewFailure : ViewData -> List Notebook.Types.MessageItem -> Element FrontendMsg
viewFailure viewData report =
    render viewData report


render : ViewData -> List Notebook.Types.MessageItem -> Element FrontendMsg
render viewData report =
    E.column
        [ E.paddingXY 8 8
        , Font.color (E.rgb 0.9 0.9 0.9)
        , Font.size 14
        , E.width (E.px 600)
        , E.height E.fill
        , E.paddingEach { top = 24, bottom = 24, left = 24, right = 0 }

        --, E.height (E.px 400)
        , E.scrollbarY
        , E.spacing 8
        , Background.color (E.rgb 0 0 0)
        ]
        (Notebook.ErrorReporter.prepareReport viewData.errorOffset report)


viewSuccess : ViewData -> Cell -> Element FrontendMsg
viewSuccess viewData cell =
    let
        realWidth =
            viewData.width - controlWidth
    in
    case cell.value of
        CVNone ->
            case Notebook.Parser.classify cell.text of
                Notebook.Parser.Expr _ ->
                    E.el
                        [ E.paddingEach { top = 12, bottom = 0, left = 0, right = 0 }
                        , View.Style.monospace
                        ]
                        (par realWidth
                            [ View.CellThemed.renderFull cell.tipe (scale 1.0 realWidth) "Nothing" ]
                        )

                Notebook.Parser.Decl _ _ ->
                    -- E.el [ E.height (E.px 30), E.width (E.px 100), E.paddingXY 24 12 ] (E.text "Ok")
                    E.none

        CVString str ->
            case Notebook.Parser.classify cell.text of
                Notebook.Parser.Expr _ ->
                    E.el
                        [ E.paddingEach { top = 12, bottom = 0, left = 0, right = 0 }
                        , View.Style.monospace
                        ]
                        (par realWidth
                            [ View.CellThemed.renderFull cell.tipe (scale 1.0 realWidth) str ]
                        )

                Notebook.Parser.Decl _ _ ->
                    -- E.el [ E.height (E.px 30), E.width (E.px 100), E.paddingXY 24 12 ] (E.text "Ok")
                    E.none

        CVMarkdown str ->
            par realWidth
                -- TODO: fix this outrageous hack
                [ E.none ]


par width =
    E.paragraph
        [ E.spacing 8
        , Font.color Color.black
        , E.width (E.px width)
        , Background.color (E.rgb 0.75 0.75 0.95)
        ]


getArg : Int -> List String -> String
getArg k args =
    List.Extra.getAt k args |> Maybe.withDefault "--"


viewIndex : Cell -> Element FrontendMsg
viewIndex cell =
    let
        action =
            case cell.cellState of
                CSView ->
                    Element.Events.onMouseDown (EditCell cell)

                CSEdit ->
                    Element.Events.onMouseDown (EvalCell cell.cellState cell.index)

        padding =
            case cell.cellState of
                CSView ->
                    E.paddingEach { top = 9, bottom = 0, left = 0, right = 16 }

                CSEdit ->
                    E.paddingEach { top = 0, bottom = 0, left = 0, right = 0 }
    in
    E.el
        [ action
        , padding
        , Font.color (E.rgba 0.1 0.1 0.7 0.5)
        , E.htmlAttribute <| HA.style "z-index" "1"
        , Font.family
            [ Font.typeface "Open Sans"
            , Font.sansSerif
            ]
        ]
        (E.text <| "Cell " ++ String.fromInt (cell.index + 1))


renderCode cell width =
    E.column
        [ E.width (E.px width)
        , E.paddingXY 12 0
        , Font.size 14
        , View.Style.monospace
        , Font.color (E.rgb 0.0 0.0 0.8)
        , E.height E.shrink
        , if not cell.locked then
            Element.Events.onMouseDown (EditCell cell)

          else
            Element.Events.onMouseDown NoOpFrontendMsg
        , E.inFront (E.el [ E.alignRight, E.moveDown 8 ] (viewIndex cell))
        ]
        [ View.Utility.preformattedElement [ HA.style "line-height" "1.5" ] cell.text
        ]



-- , Styled.style [ ( "z-index", "1" ) ]


renderMarkdown cell width =
    E.column
        [ E.spacing 0
        , if not cell.locked then
            Element.Events.onMouseDown (EditCell cell)

          else
            Element.Events.onMouseDown NoOpFrontendMsg
        , E.width (E.px width)
        , E.inFront (E.el [ E.alignRight, E.moveDown 4 ] (viewIndex cell))
        , Font.size 14
        , Font.family
            [ Font.typeface "Open Sans"
            , Font.sansSerif
            ]
        ]
        [ View.CellThemed.renderFull cell.tipe (width - 54) cell.text
        ]


stepFunction : List ( number, number ) -> number -> number
stepFunction steps x =
    List.Extra.find (\( a, b ) -> x <= a) steps |> Maybe.map Tuple.second |> Maybe.withDefault 0


scale : Float -> Int -> Int
scale factor x =
    round <| factor * toFloat x


editBGColor =
    Background.color (E.rgb 0.2 0.2 0.35)


editCell : Int -> Cell -> String -> Element FrontendMsg
editCell width cell cellContent =
    E.el
        [ E.paddingXY 8 4
        , bgColor cell
        , Element.Border.color (E.rgb 1.0 0.6 0.6)
        , editBGColor
        ]
        (E.column
            [ E.spacing 8
            , E.paddingEach { top = 1, right = 1, bottom = 1, left = 1 }
            , E.width (E.px <| width - 16)
            ]
            [ Element.Input.multiline
                [ bgColor cell
                , Font.color Color.black
                , E.centerX
                , E.width (E.px <| width)
                , View.Style.monospace
                ]
                { onChange = InputElmCode cell.index
                , text = cellContent
                , placeholder = Nothing
                , label = Element.Input.labelHidden ""
                , spellcheck = False
                }
            ]
        )


newCellAboveOrBelow : Notebook.Types.CellDirection -> Element FrontendMsg
newCellAboveOrBelow cellDirection =
    case cellDirection of
        Notebook.Types.Up ->
            Button.smallPrimary { msg = ChangeCellInsertionDirection Notebook.Types.Down, status = Button.Highlighted, label = Button.Text "Above", tooltipText = Just "Insert new cell above" }

        Notebook.Types.Down ->
            Button.smallPrimary { msg = ChangeCellInsertionDirection Notebook.Types.Up, status = Button.Highlighted, label = Button.Text "Below", tooltipText = Just "Insert ew cell below " }


newCodeCellAt : CellState -> Int -> Element FrontendMsg
newCodeCellAt cellState index =
    case cellState of
        CSView ->
            Button.smallPrimary { msg = NewCodeCell CSEdit index, status = Button.Active, label = Button.Text "New Code", tooltipText = Just "Insert  new cell" }

        CSEdit ->
            Button.smallPrimary { msg = NewCodeCell CSEdit index, status = Button.Active, label = Button.Text "New Code", tooltipText = Just "Insert  new cell" }


newMarkdownCellAt : CellState -> Int -> Element FrontendMsg
newMarkdownCellAt cellState index =
    case cellState of
        CSView ->
            Button.smallPrimary { msg = NewMarkdownCell CSEdit index, status = Button.Active, label = Button.Text "New Text", tooltipText = Just "Insert  new cell" }

        CSEdit ->
            Button.smallPrimary { msg = NewMarkdownCell CSEdit index, status = Button.Active, label = Button.Text "New Text", tooltipText = Just "Insert  new cell" }


newCodeCellBangAt : CellState -> Int -> Element FrontendMsg
newCodeCellBangAt cellState index =
    case cellState of
        CSView ->
            Button.smallPrimary { msg = NewCodeCell CSView index, status = Button.Active, label = Button.Text "New Code", tooltipText = Just "Insert  new cell" }

        CSEdit ->
            Button.smallPrimary { msg = NewCodeCell CSView index, status = Button.Active, label = Button.Text "New Code", tooltipText = Just "Insert  new cell" }


newMarkdownCellBangAt : CellState -> Int -> Element FrontendMsg
newMarkdownCellBangAt cellState index =
    case cellState of
        CSView ->
            Button.smallPrimary { msg = NewMarkdownCell CSView index, status = Button.Active, label = Button.Text "New Text", tooltipText = Just "Insert  new cell" }

        CSEdit ->
            Button.smallPrimary { msg = NewMarkdownCell CSView index, status = Button.Active, label = Button.Text "New Text", tooltipText = Just "Insert  new cell" }


deleteCellAt : CellState -> Int -> Element FrontendMsg
deleteCellAt cellState index =
    --case cellState of
    --    CSView ->
    Button.smallPrimary { msg = DeleteCell index, status = Button.Active, label = Button.Text "Delete", tooltipText = Just "Delete cell" }



--CSEdit ->
--    E.none


clearCellAt : CellState -> Int -> Element FrontendMsg
clearCellAt cellState index =
    Button.smallPrimary { msg = ClearCell index, status = Button.Active, label = Button.Text "Clear", tooltipText = Just "Edit cell" }
