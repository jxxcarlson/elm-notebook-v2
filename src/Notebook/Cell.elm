module Notebook.Cell exposing (..)

import Notebook.Types


type alias Cell =
    { index : Int
    , text : String
    , tipe : CellType
    , value : CellValue
    , cellState : CellState
    , commented : Bool
    , locked : Bool
    , report : ( Int, Maybe (List Notebook.Types.MessageItem) )
    , replData : Maybe Notebook.Types.ReplData
    , highlightTime : Int
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
    | CSEditCompact
    | CSView


locate : String -> List Cell -> List Int
locate text cells =
    List.map .index <| List.filter (\cell -> String.contains text cell.text && cell.tipe == CTCode) cells


hasErrors : List Cell -> Bool
hasErrors cells =
    List.any (\cell -> Tuple.second cell.report /= Nothing) cells


uncomment : Cell -> Cell
uncomment cell =
    { cell | commented = False, text = uncommentText cell.text }


comment : Cell -> Cell
comment cell =
    { cell | commented = True, text = commentText cell.text }


commentText : String -> String
commentText text =
    let
        commentLine line =
            "-- " ++ line

        lines =
            String.lines text

        commentedLines =
            List.map commentLine lines
    in
    String.join "\n" commentedLines


uncommentText : String -> String
uncommentText text =
    let
        uncommentLine line =
            if String.startsWith "-- " line then
                String.dropLeft 3 line

            else
                line

        lines =
            String.lines text

        uncommentedLines =
            List.map uncommentLine lines
    in
    String.join "\n" uncommentedLines
