module Notebook.Book exposing
    ( Book
    , DirectionToMove(..)
    , Theme(..)
    , ViewData
    , clearValues
    , copy
    , decrementHighlightTime
    , initializeCellState
    , moveCellUpDown
    , new
    , replaceCell
    , resetHighlightTime
    , scratchPad
    , setAllCellStates
    , setCellState
    , setCellType
    , setReplDataAt
    )

import Dict exposing (Dict)
import Keyboard
import Lamdera
import List.Extra
import Notebook.Cell exposing (Cell, CellState(..), CellType(..), CellValue(..))
import Notebook.Types
import Time


type alias Book =
    { id : String
    , dirty : Bool
    , slug : String
    , origin : Maybe String
    , author : String
    , createdAt : Time.Posix
    , updatedAt : Time.Posix
    , public : Bool
    , title : String
    , cells : List Notebook.Cell.Cell
    , currentIndex : Int
    , packageNames : List String
    , tags : List String
    , options : Dict String String
    }


copy : Book -> Book
copy book =
    { id = book.id ++ "C"
    , dirty = False
    , slug = book.slug ++ "C"
    , origin = book.origin
    , author = book.author
    , createdAt = book.createdAt
    , updatedAt = book.createdAt
    , public = book.public
    , title = book.title ++ " (Copy)"
    , cells = book.cells
    , currentIndex = 0
    , packageNames = book.packageNames
    , tags = book.tags
    , options = book.options
    }


type Theme
    = DarkTheme
    | LightTheme


type DirectionToMove
    = Up
    | Down


scratchPad : String -> Book
scratchPad username =
    { id = "_scratchpad_"
    , slug = username ++ ".scratchpad"
    , origin = Nothing
    , author = username
    , dirty = False
    , createdAt = Time.millisToPosix 0
    , updatedAt = Time.millisToPosix 0
    , public = False
    , title = "Scatchpad"
    , cells =
        [ { index = 0
          , text = "This is a *test*"
          , tipe = CTMarkdown
          , value = CVMarkdown "This is a *test*"
          , cellState = CSView
          , commented = False
          , locked = False
          , report = ( 0, Nothing )
          , replData = Nothing
          , highlightTime = 0
          }
        , { index = 1
          , text = "1 + 1"
          , tipe = CTCode
          , value = CVNone
          , cellState = CSView
          , commented = False
          , locked = False
          , report = ( 1, Nothing )
          , replData = Nothing
          , highlightTime = 0
          }
        ]
    , currentIndex = 0
    , packageNames = []
    , tags = []
    , options = Dict.fromList []
    }


clearValues : Book -> Book
clearValues book =
    { book
        | cells =
            List.map
                (\cell ->
                    { cell
                        | value = CVNone
                        , cellState = CSView
                        , report = ( cell.index, Nothing )
                        , replData = Nothing
                    }
                )
                book.cells
    }


new : String -> String -> Book
new author title =
    { id = "??"
    , slug = "??"
    , author = author
    , origin = Nothing
    , dirty = False
    , createdAt = Time.millisToPosix 0
    , updatedAt = Time.millisToPosix 0
    , public = False
    , title = title
    , cells =
        [ { index = 0
          , text = "This is a *test*"
          , tipe = CTMarkdown
          , value = CVMarkdown "This is a *test*"
          , cellState = CSView
          , commented = False
          , locked = False
          , report = ( 0, Nothing )
          , replData = Nothing
          , highlightTime = 0
          }
        , { index = 1
          , text = "1 + 1"
          , tipe = CTCode
          , value = CVNone
          , cellState = CSView
          , commented = False
          , locked = False
          , report = ( 0, Nothing )
          , replData = Nothing
          , highlightTime = 0
          }
        ]
    , currentIndex = 0
    , packageNames = []
    , tags = []
    , options = Dict.fromList []
    }


newBook : String -> String -> Book
newBook author title =
    { id = ""
    , slug = ""
    , origin = Nothing
    , author = author
    , dirty = False
    , createdAt = Time.millisToPosix 0
    , updatedAt = Time.millisToPosix 0
    , public = False
    , title = title
    , cells =
        [ { index = 0
          , text = "This is a *test*"
          , tipe = CTMarkdown
          , value = CVMarkdown "This is a *test*"
          , cellState = CSView
          , commented = False
          , locked = False
          , report = ( 0, Nothing )
          , replData = Nothing
          , highlightTime = 0
          }
        , { index = 1
          , text = "1 + 1"
          , tipe = CTCode
          , value = CVNone
          , cellState = CSView
          , commented = False
          , locked = False
          , report = ( 1, Nothing )
          , replData = Nothing
          , highlightTime = 0
          }
        ]
    , currentIndex = 0
    , packageNames = []
    , tags = []
    , options = Dict.fromList []
    }


resetHighlightTime : Book -> Book
resetHighlightTime book =
    { book
        | cells =
            List.map
                (\cell ->
                    { cell | highlightTime = 0 }
                )
                book.cells
    }


decrementHighlightTime : Book -> Book
decrementHighlightTime book =
    { book
        | cells =
            List.map
                (\cell ->
                    { cell | highlightTime = max 0 (cell.highlightTime - 1) }
                )
                book.cells
    }


initialStateString =
    "10"


initialStateExpression =
    "if state <= 0 then 0 else state + ds p0"


initialStateBindings =
    [ "ds p = if p < 0.5 then -1 else 1" ]


initializeCellState : Book -> Book
initializeCellState book =
    { book | cells = List.map (\cell -> { cell | cellState = CSView }) book.cells }


type alias ViewData =
    { book : Book
    , kvDict : Dict String String
    , width : Int
    , ticks : Int
    , cellDirection : Notebook.Types.CellDirection
    , errorOffset : Int
    , theme : Theme
    , pressedKeys : List Keyboard.Key
    }


apply : (Notebook.Cell.Cell -> Notebook.Cell.Cell) -> Book -> Book
apply f book =
    { book | cells = List.map f book.cells }


setAllCellStates : CellState -> Book -> Book
setAllCellStates cellState book =
    -- { book | cells = List.map (\cell -> { cell | cellState = cellState }) book.cells }
    apply (\cell -> { cell | cellState = cellState }) book


clearReplData : CellState -> Book -> Book
clearReplData cellState book =
    -- { book | cells = List.map (\cell -> { cell | replData = Nothing }) book.cells }
    apply (\cell -> { cell | replData = Nothing }) book


setReplDataAt : Int -> Maybe (List Notebook.Types.MessageItem) -> Book -> Book
setReplDataAt index report book =
    let
        cells =
            book.cells
    in
    { book
        | cells =
            List.map
                (\cell ->
                    if cell.index == index then
                        { cell | report = ( index, report ) }

                    else
                        cell
                )
                cells
    }


replaceCell : Cell -> Book -> Book
replaceCell cell book =
    let
        cells =
            book.cells
    in
    { book
        | cells =
            List.map
                (\c ->
                    if c.index == cell.index then
                        cell

                    else
                        c
                )
                cells
    }


setCellType : Cell -> CellType -> Book -> Book
setCellType cell cellType book =
    let
        cells =
            book.cells
    in
    { book
        | cells =
            List.map
                (\c ->
                    if c.index == cell.index then
                        { c | tipe = cellType }

                    else
                        c
                )
                cells
    }


setCellState : Cell -> CellState -> Book -> Book
setCellState cell cellState book =
    let
        cells =
            book.cells
    in
    { book
        | cells =
            List.map
                (\c ->
                    if c.index == cell.index then
                        { c | cellState = cellState }

                    else
                        c
                )
                cells
    }


moveCellUpDown model index direction =
    case direction of
        Down ->
            case ( List.Extra.getAt index model.currentBook.cells, List.Extra.getAt (index + 1) model.currentBook.cells ) of
                ( Just cell, Just cellBelow ) ->
                    let
                        newCellBelow =
                            { cell | index = index + 1 }

                        newCell =
                            { cellBelow | index = index }

                        currentBook =
                            model.currentBook
                                |> replaceCell newCellBelow
                                |> replaceCell newCell
                    in
                    ( { model | currentBook = currentBook }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        Up ->
            case ( List.Extra.getAt index model.currentBook.cells, List.Extra.getAt (index - 1) model.currentBook.cells ) of
                ( Just cell, Just cellAbove ) ->
                    let
                        newCellAbove =
                            { cell | index = index - 1 }

                        newCell =
                            { cellAbove | index = index }

                        currentBook =
                            model.currentBook
                                |> replaceCell newCellAbove
                                |> replaceCell newCell
                    in
                    ( { model | currentBook = currentBook }, Cmd.none )

                _ ->
                    ( model, Cmd.none )
