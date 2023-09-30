module Notebook.Book exposing
    ( Book
    , ViewData
    , initializeCellState
    , new
    , scratchPad
    , setAllCellStates
    , setReplDataAt
    )

import Dict exposing (Dict)
import Notebook.Cell exposing (Cell, CellState(..), CellType(..), CellValue(..))
import Notebook.ErrorReporter
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
    }


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
          , locked = False
          , report = Nothing
          }
        , { index = 1
          , text = "1 + 1"
          , tipe = CTCode
          , value = CVNone
          , cellState = CSView
          , locked = False
          , report = Nothing
          }
        ]
    , currentIndex = 0
    }


type alias Cell =
    { index : Int
    , text : String
    , tipe : CellType
    , value : CellValue
    , cellState : CellState
    , locked : Bool
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
          , locked = False
          , report = Nothing
          }
        , { index = 1
          , text = "1 + 1"
          , tipe = CTCode
          , value = CVNone
          , cellState = CSView
          , locked = False
          , report = Nothing
          }
        ]
    , currentIndex = 0
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
          , locked = False
          , report = Nothing
          }
        , { index = 1
          , text = "1 + 1"
          , tipe = CTCode
          , value = CVNone
          , cellState = CSView
          , locked = False
          , report = Nothing
          }
        ]
    , currentIndex = 0
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
    }


setAllCellStates : CellState -> Book -> Book
setAllCellStates cellState book =
    { book | cells = List.map (\cell -> { cell | cellState = cellState }) book.cells }


setReplDataAt : Int -> Maybe (List Notebook.ErrorReporter.MessageItem) -> Book -> Book
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
                        { cell | report = report }

                    else
                        cell
                )
                cells
    }
