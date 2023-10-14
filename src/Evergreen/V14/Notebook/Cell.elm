module Evergreen.V14.Notebook.Cell exposing (..)

import Evergreen.V14.Notebook.Types


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


type alias Cell =
    { index : Int
    , text : String
    , tipe : CellType
    , value : CellValue
    , cellState : CellState
    , locked : Bool
    , report : Maybe (List Evergreen.V14.Notebook.Types.MessageItem)
    , replData : Maybe Evergreen.V14.Notebook.Types.ReplData
    }
