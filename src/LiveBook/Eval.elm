module LiveBook.Eval exposing
    ( evaluate
    , evaluateSource
    , evaluateWithCumulativeBindings
    , getCellBindings
    , testCell
    )

import Eval
import List.Extra
import Types exposing (Cell, CellState(..))
import Value exposing (Value)


cText =
    """
factoriaTC n =
    let
        f x acc =
            if x == 0 then
                acc
            else
                f (x - 1) (x * acc)
    in
    f n 1
"""



--{ index : Int, text : List String, value : Maybe String, cellState : CellState }


testCell =
    { index = 0, text = String.lines cText, value = Nothing, cellState = CSView }


evaluate : Cell -> Cell
evaluate cell =
    { cell | value = evaluateSource cell, cellState = CSView }


evaluateWithCumulativeBindings : List Cell -> Cell -> Cell
evaluateWithCumulativeBindings cells cell =
    let
        cellSourceLines =
            cell.text
                |> List.filter (\s -> String.left 1 s /= "#")
                |> List.filter (\s -> String.trim s /= "")
    in
    if (List.head cellSourceLines |> Maybe.map String.trim) == Just "let" then
        { cell | value = Just <| evaluateString (cellSourceLines |> String.join "\n"), cellState = CSView }

    else
        let
            bindings =
                getPriorBindings cell.index cells

            lines =
                cell.text
                    |> List.filter (\s -> String.left 1 s /= "#")
                    |> List.filter (\s -> String.trim s /= "")

            n =
                List.length lines

            expression : List String
            expression =
                List.drop (n - 1) lines

            isBinding : List String -> Bool
            isBinding list =
                case list |> List.head |> Maybe.map (String.contains "=") of
                    Just True ->
                        True

                    _ ->
                        False

            --_ =
            --    isBinding (expression |> Debug.log "EXPR") |> Debug.log "IS_BINDING (expression)"
            value =
                if bindings == [] then
                    expression |> String.join "\n" |> evaluateString

                else if isBinding expression then
                    "()" |> evaluateString

                else if Maybe.map (String.contains "let") (List.Extra.getAt 1 lines) == Just True then
                    "()" |> evaluateString

                else
                    "let"
                        --:: ((bindings |> Debug.log "BINDINGS") ++ [ "in" ] ++ expression)
                        :: (bindings ++ [ "in" ] ++ expression)
                        |> String.join "\n"
                        |> evaluateString
        in
        { cell | value = Just value, cellState = CSView }


evaluateSource : Cell -> Maybe String
evaluateSource cell =
    evaluateString (sourceText_ cell |> toLetInExpression |> String.join "\n") |> Just



-- BINDINGS


getCellBindings : Cell -> List String
getCellBindings cell =
    let
        lines =
            sourceText_ cell

        firstLine =
            List.head lines |> Maybe.map String.trim |> Maybe.withDefault "---"
    in
    if firstLine == "let" then
        []

    else if String.contains "==" firstLine then
        []

    else if String.contains "=" firstLine then
        let
            n =
                List.length lines

            last =
                List.drop (n - 1) lines |> List.head |> Maybe.withDefault ""

            --
            --_ =
            --    Debug.log "COND 1" (Maybe.map (String.contains "let") (List.Extra.getAt 1 lines) == Just True)
            --
            --_ =
            --    Debug.log "COND 2" (String.contains "=" last)
        in
        if Maybe.map (String.contains "let") (List.Extra.getAt 1 lines) == Just True then
            lines

        else if String.contains "=" last then
            lines

        else if String.left 4 (String.trim last) == "else" then
            lines

        else
            List.take (n - 1) lines

    else
        []


getPriorBindings : Int -> List Cell -> List String
getPriorBindings k cells =
    cells
        |> List.take (k + 1)
        |> List.map getCellBindings
        |> List.concat


toLetInExpression : List String -> List String
toLetInExpression lines =
    if (List.head lines |> Maybe.map String.trim) == Just "let" then
        lines

    else
        let
            n =
                List.length lines

            letBody =
                List.take (n - 1) lines

            lastLine =
                List.drop (n - 1) lines
        in
        if n < 2 then
            lines

        else
            "let" :: (letBody ++ ("in" :: lastLine))


sourceText_ : Cell -> List String
sourceText_ cell =
    cell.text
        |> List.filter (\s -> String.left 1 s /= "#")
        |> List.filter (\s -> String.trim s /= "")


evaluateString : String -> String
evaluateString input =
    case Eval.eval input |> Result.map Value.toString of
        Ok output ->
            output

        Err err ->
            "Error"
