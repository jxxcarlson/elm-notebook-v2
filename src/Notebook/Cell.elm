module Notebook.Cell exposing (..)

import Notebook.Types


type alias Cell =
    { index : Int
    , text : String
    , tipe : CellType
    , value : CellValue
    , cellState : CellState
    , locked : Bool
    , report : Maybe (List Notebook.Types.MessageItem)
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


locate : String -> List Cell -> List Int
locate text cells =
    List.map .index <| List.filter (\cell -> String.contains text cell.text && cell.tipe == CTCode) cells


hasErrors : List Cell -> Bool
hasErrors cells =
    List.any (\cell -> cell.report /= Nothing) cells
