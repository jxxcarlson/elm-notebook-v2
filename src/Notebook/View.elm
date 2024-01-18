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
import Notebook.Config
import Notebook.ErrorReporter
import Notebook.Parser
import Notebook.ThemedColor exposing (..)
import Notebook.Types
import Notebook.Utility as Utility
import Types exposing (FrontendModel, FrontendMsg(..))
import UILibrary.Button as Button
import View.Button exposing (runCell)
import View.CellThemed
import View.Style
import View.Utility


view : Int -> ViewData -> String -> Cell -> Element FrontendMsg
view currentCellIndex viewData cellContents cell =
    E.column
        [ E.width (E.px viewData.width)
        , if currentCellIndex == cell.index then
            Background.color (E.rgb 0.5 0.9 0.8)

          else if currentCellIndex == cell.index + 1 then
            Background.color (E.rgb 0.5 0.5 0.9)

          else
            Background.color (themedBackgroundColor viewData.theme)
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
                    [ Element.Border.color (themedDividerColor originalviewData.theme) -- (E.rgb 0.75 0.75 0.75)

                    --, editBGColor
                    , Element.Border.widthEach
                        { bottom = 1
                        , left = 0
                        , right = 0
                        , top = 1
                        }
                    ]

                ( CSView, CTCode ) ->
                    [ Element.Border.color (themedDividerColor originalviewData.theme) -- (E.rgb 0 0 1.0)
                    , Element.Border.widthEach
                        { bottom = 0 -- 1
                        , left = 0
                        , right = 0
                        , top = 1
                        }
                    ]

                ( CSView, CTMarkdown ) ->
                    [ Element.Border.color (themedDividerColor originalviewData.theme) -- (E.rgb 0.75 0.75 0.75)
                    , Element.Border.widthEach
                        { bottom = 0
                        , left = 0
                        , right = 0
                        , top = 1
                        }
                    , Background.color (themedBackgroundColor viewData.theme)
                    ]

        viewData =
            { originalviewData | width = originalviewData.width - 24 }
    in
    E.column
        ([ if cell.highlightTime > 0 then
            Background.color (E.rgba 1 0 0 1.0)

           else
            Background.color (themedCodeCellBackgroundColor viewData.theme)
         , Font.color (themedCodeCellTextColor viewData.theme) -- (Utility.cellColor cell.tipe)
         ]
            ++ style
        )
        [ E.el
            [ E.alignRight
            , if cell.highlightTime > 0 then
                Background.color (E.rgba 1 0 0 1.0)

              else
                Background.color (Utility.cellColor cell.tipe)
            ]
            (controls viewData cell)
        , E.row []
            [ viewSource viewData (viewData.width - controlWidth) cell cellContents
            , E.column [] [ newCodeCellAt cell.cellState cell.index, View.Button.runCellSmall cell.cellState cell.tipe cell.index ]
            ]
        , E.el
            []
            (viewValue viewData cell)
        ]


hrule theme cell =
    case cell.tipe of
        CTCode ->
            [ Element.Border.widthEach { top = 2, bottom = 0, left = 0, right = 0 }
            , Element.Border.color (themedCodeCellTextColor theme) --(E.rgba 0.75 0.75 1.0 0.8)
            ]

        CTMarkdown ->
            []


bgColor cell =
    Background.color (Utility.cellColor cell.tipe)


controls viewData cell =
    case cell.cellState of
        CSView ->
            E.none

        CSEdit ->
            E.row
                [ --controlBGEdit
                  E.width (E.px (viewData.width - 3))
                , E.centerX
                , E.paddingEach { left = 0, right = 12, bottom = 0, top = 0 }

                --, bgColor cell
                , Background.color (themedBackgroundColor viewData.theme) --      bgColor cell
                , Font.color (themedTextColor viewData.theme)
                ]
                [ E.row
                    [ E.spacing 2
                    , E.alignLeft
                    , E.height (E.px 32)
                    , E.spacing 12
                    , E.paddingEach { top = 2, bottom = 2, left = 8, right = 4 }
                    ]
                    [ --E.row [ E.spacing 6 ]
                      --    [ E.row [ E.spacing 0 ]
                      --        [ newCellAboveOrBelow viewData.cellDirection
                      --        , E.el [ E.paddingEach { left = 12, right = 7, top = 0, bottom = 0 }, Font.color (themedMutedTextColor viewData.theme) ] (E.text "New:")
                      --
                      --        -- , newCodeCellAt cell.cellState cell.index
                      --        , newMarkdownCellAt cell.cellState cell.index
                      --        ]
                      --    ]
                      E.row []
                        [ deleteCellAt cell.cellState cell.index
                        , clearCellAt cell.cellState cell.index
                        ]
                    , E.row
                        [ E.spacing 0
                        , E.alignRight
                        , E.height (E.px 32)
                        , E.paddingEach { top = 0, bottom = 2, left = 8, right = 18 }
                        ]
                        [ moveCell cell.cellState cell.index Notebook.Book.Up
                        , moveCell cell.cellState cell.index Notebook.Book.Down
                        ]
                    , E.row [ E.spacing 0 ]
                        [ toggleCellType cell
                        , commentCell cell.commented cell.index
                        ]

                    --, View.Button.lockCell cell
                    ]
                , E.row
                    [ E.spacing 6
                    , E.alignRight
                    , E.height (E.px 32)
                    , E.paddingEach { top = 2, bottom = 2, left = 8, right = 4 }
                    ]
                    [ viewIndex viewData.theme cell
                    ]
                ]


controlWidth =
    0


viewSource : ViewData -> Int -> Cell -> String -> Element FrontendMsg
viewSource viewData width cell cellContent =
    case cell.cellState of
        CSView ->
            case cell.tipe of
                CTCode ->
                    renderCode viewData.pressedKeys viewData.theme cell width

                CTMarkdown ->
                    renderMarkdown viewData.theme cell width

        CSEdit ->
            editCell viewData.theme width cell cellContent


viewValue : ViewData -> Cell -> Element FrontendMsg
viewValue viewData cell =
    case cell.tipe of
        CTMarkdown ->
            E.none

        CTCode ->
            case cell.report of
                ( _, Just report ) ->
                    viewFailure viewData cell report

                ( _, Nothing ) ->
                    viewSuccess viewData cell


viewFailure : ViewData -> Cell -> List Notebook.Types.MessageItem -> Element FrontendMsg
viewFailure viewData cell report =
    E.el [ Font.color (E.rgb 1 0.5 0), E.height (E.px 30), E.paddingXY 6 6, E.width (E.px 700), Background.color (E.rgb 0 0 0) ] (E.text "Error")


viewSuccess : ViewData -> Cell -> Element FrontendMsg
viewSuccess viewData cell =
    -- TODO
    let
        realWidth =
            viewData.width - controlWidth
    in
    case cell.value of
        CVNone ->
            case Notebook.Parser.classify cell.text of
                Err _ ->
                    E.none

                Ok classif ->
                    case classif of
                        Notebook.Parser.Expr _ ->
                            E.el
                                [ Element.Events.onMouseDown (ExecuteCell cell.index)
                                , View.Style.monospace
                                ]
                                (par cell.highlightTime
                                    viewData.theme
                                    realWidth
                                    [ E.text "No value" ]
                                )

                        Notebook.Parser.Decl _ _ ->
                            E.none

                        _ ->
                            E.none

        CVString str ->
            case Notebook.Parser.classify cell.text of
                Err _ ->
                    E.none

                Ok classif ->
                    case classif of
                        Notebook.Parser.Expr _ ->
                            E.el
                                [ View.Style.monospace
                                ]
                                (par cell.highlightTime
                                    viewData.theme
                                    realWidth
                                    -- [ View.CellThemed.renderFull viewData.theme cell.tipe (scale 1.0 realWidth) str ]
                                    [ E.text str ]
                                )

                        Notebook.Parser.Decl _ _ ->
                            -- E.el [ E.height (E.px 30), E.width (E.px 100), E.paddingXY 24 12 ] (E.text "Ok")
                            E.none

                        _ ->
                            E.none

        CVMarkdown str ->
            par cell.highlightTime
                viewData.theme
                realWidth
                -- TODO: fix this outrageous hack
                [ E.none ]


par highlightTime theme width =
    E.paragraph
        [ E.spacing 8
        , if highlightTime > 0 then
            Font.color (themedValueHighlightedTextColor theme)

          else
            Font.color (themedValueTextColor theme)
        , E.width (E.px width)
        , E.paddingXY 12 12
        , if highlightTime > 0 then
            Background.color (themedHighlightColor theme)

          else
            Background.color (themedValueBackgroundColor theme)
        ]


getArg : Int -> List String -> String
getArg k args =
    List.Extra.getAt k args |> Maybe.withDefault "--"


viewIndex : Notebook.Book.Theme -> Cell -> Element FrontendMsg
viewIndex theme cell =
    -- TODO: rethink action
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
                    E.paddingEach { top = 9, bottom = 6, left = 6, right = 16 }

                CSEdit ->
                    E.paddingEach { top = 6, bottom = 6, left = 12, right = 16 }
    in
    E.el
        [ action
        , padding
        , Background.color
            (case cell.tipe of
                CTCode ->
                    themedButtonColor cell.tipe cell.cellState theme

                CTMarkdown ->
                    themedButtonColor cell.tipe cell.cellState theme
            )
        , Font.color (themedMutedTextColor theme)
        , E.htmlAttribute <| HA.style "z-index" "1"
        , E.htmlAttribute <| HA.style "cursor" "pointer"
        , Font.family
            [ Font.typeface "Open Sans"
            , Font.sansSerif
            ]
        ]
        (E.text <| "Cell " ++ String.fromInt (cell.index + 1))


renderCode pressedKeys theme cell width =
    E.column
        [ E.width (E.px width)
        , E.paddingXY 12 0
        , Font.size 14
        , View.Style.monospace
        , Font.color (themedCodeCellTextColor theme)
        , Background.color (themedCodeCellBackgroundColor theme)
        , E.height E.shrink
        , if not cell.locked then
            case cell.cellState of
                CSView ->
                    -- TODO: review this.  We disabled auto-editing for now
                    -- TODO: and are going to make clickng in the cell make
                    -- TODO: the cell current
                    --  Element.Events.onMouseDown (EditCell cell)
                    Element.Events.onMouseDown (MakeCellCurrent cell.index)

                CSEdit ->
                    Element.Events.onMouseDown (EvalCell CSEdit cell.index)

          else
            Element.Events.onMouseDown NoOpFrontendMsg
        , E.inFront (E.el [ E.alignRight, E.moveDown 8 ] (viewIndex theme cell))
        ]
        [ View.Utility.preformattedElement [ HA.style "line-height" "1.5" ] cell.text
        ]



-- , Styled.style [ ( "z-index", "1" ) ]


renderMarkdown theme cell width =
    E.column
        [ E.spacing 0

        --, if not cell.locked then
        --    Element.Events.onMouseDown (EditCell cell)
        --
        --  else
        --    Element.Events.onMouseDown NoOpFrontendMsg
        , E.width (E.px width)
        , E.inFront (E.el [ E.alignRight, E.moveDown 4 ] (viewIndex theme cell))
        , Font.size 14
        , Font.family
            [ Font.typeface "Open Sans"
            , Font.sansSerif
            ]
        , Background.color
            (case theme of
                Notebook.Book.LightTheme ->
                    Notebook.Config.lightThemeBackgroundColor

                Notebook.Book.DarkTheme ->
                    Notebook.Config.darkThemeBackgroundColor
            )
        ]
        [ View.CellThemed.renderFull theme cell.tipe (width - 54) cell.text
        ]


stepFunction : List ( number, number ) -> number -> number
stepFunction steps x =
    List.Extra.find (\( a, b ) -> x <= a) steps |> Maybe.map Tuple.second |> Maybe.withDefault 0


scale : Float -> Int -> Int
scale factor x =
    round <| factor * toFloat x


editBGColor =
    Background.color (E.rgb 0.2 0.2 0.35)


editCell : Notebook.Book.Theme -> Int -> Cell -> String -> Element FrontendMsg
editCell theme width cell cellContent =
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
                [ Background.color (themedBackgroundColor theme) --      bgColor cell
                , Font.color (themedTextColor theme)
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
            Button.smallPrimary { msg = ChangeCellInsertionDirection Notebook.Types.Down, status = Button.ActiveRunningSpecial, label = Button.Text "Above", tooltipText = Just "Insert new cell above" }

        Notebook.Types.Down ->
            Button.smallPrimary { msg = ChangeCellInsertionDirection Notebook.Types.Up, status = Button.ActiveRunningSpecial, label = Button.Text "Below", tooltipText = Just "Insert ew cell below " }


newCodeCellAt : CellState -> Int -> Element FrontendMsg
newCodeCellAt cellState index =
    case cellState of
        CSView ->
            Button.smallPrimary { msg = NewCodeCell CSEdit index, status = Button.ActiveTransparent, label = Button.Text "+", tooltipText = Just "Insert  new code cell" }

        CSEdit ->
            Button.smallPrimary { msg = NewCodeCell CSEdit index, status = Button.ActiveTransparent, label = Button.Text "+", tooltipText = Just "Insert  new code cell" }


newMarkdownCellAt : CellState -> Int -> Element FrontendMsg
newMarkdownCellAt cellState index =
    case cellState of
        CSView ->
            Button.smallPrimary { msg = NewMarkdownCell CSEdit index, status = Button.ActiveTransparent, label = Button.Text "Text", tooltipText = Just "Insert  new cell" }

        CSEdit ->
            Button.smallPrimary { msg = NewMarkdownCell CSEdit index, status = Button.ActiveTransparent, label = Button.Text "Text", tooltipText = Just "Insert  new cell" }


newCodeCellBangAt : CellState -> Int -> Element FrontendMsg
newCodeCellBangAt cellState index =
    case cellState of
        CSView ->
            Button.smallPrimary { msg = NewCodeCell CSView index, status = Button.Active, label = Button.Text "New Code", tooltipText = Just "Insert  new cell" }

        CSEdit ->
            Button.smallPrimary { msg = NewCodeCell CSView index, status = Button.Active, label = Button.Text "New Code", tooltipText = Just "Insert  new cell" }


deleteCellAt : CellState -> Int -> Element FrontendMsg
deleteCellAt cellState index =
    --case cellState of
    --    CSView ->
    Button.smallPrimary { msg = DeleteCell index, status = Button.ActiveTransparent, label = Button.Text "Delete", tooltipText = Just "Delete cell" }


moveCell : CellState -> Int -> Notebook.Book.DirectionToMove -> Element FrontendMsg
moveCell cellstate index direction =
    case direction of
        Notebook.Book.Down ->
            Button.smallPrimary { msg = MoveCell index direction, status = Button.ActiveTransparent, label = Button.Text "Down", tooltipText = Just "Move cell down" }

        Notebook.Book.Up ->
            Button.smallPrimary { msg = MoveCell index direction, status = Button.ActiveTransparent, label = Button.Text "Up", tooltipText = Just "Move cell up" }


commentCell : Bool -> Int -> Element FrontendMsg
commentCell commented index =
    case commented of
        True ->
            Button.smallPrimary { msg = ToggleComment commented index, status = Button.ActiveTransparent, label = Button.Text "Uncomment", tooltipText = Just "Uncomment cell" }

        False ->
            Button.smallPrimary { msg = ToggleComment commented index, status = Button.ActiveTransparent, label = Button.Text "Comment", tooltipText = Just "Comment cell" }


clearCellAt : CellState -> Int -> Element FrontendMsg
clearCellAt cellState index =
    Button.smallPrimary { msg = ClearCell index, status = Button.ActiveTransparent, label = Button.Text "Clear", tooltipText = Just "Edit cell" }
