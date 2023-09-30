module Notebook.Cell exposing (..)

import Notebook.ErrorReporter
import Notebook.Types


type alias Cell =
    { index : Int
    , text : String
    , tipe : CellType
    , value : CellValue
    , cellState : CellState
    , locked : Bool
    , report : Maybe (List Notebook.ErrorReporter.MessageItem)
    , replData : Maybe Notebook.Types.ReplData
    }


type CellType
    = CTCode
    | CTMarkdown


type CellValue
    = CVString String
    | CVMarkdown String
    | CVNone


type CellState
    = CSEdit
    | CSView
