module Evergreen.V107.Notebook.Cell exposing (..)

import Evergreen.V107.Notebook.Types


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
    , report : ( Int, Maybe (List Evergreen.V107.Notebook.Types.MessageItem) )
    , replData : Maybe Evergreen.V107.Notebook.Types.ReplData
    }
