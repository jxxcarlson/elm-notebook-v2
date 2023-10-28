module Evergreen.V113.Notebook.Cell exposing (..)

import Evergreen.V113.Notebook.Types


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
    , commented : Bool
    , locked : Bool
    , report : ( Int, Maybe (List Evergreen.V113.Notebook.Types.MessageItem) )
    , replData : Maybe Evergreen.V113.Notebook.Types.ReplData
    }
