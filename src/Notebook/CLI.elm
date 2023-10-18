module Notebook.CLI exposing (..)

import Lamdera
import Notebook.Book
import Parser as P exposing ((|.), (|=))
import Types


{-| Examples:

  - removeCells 4 12

-}
type Command
    = RemoveCells Int Int


executeCommand : Types.FrontendModel -> ( Types.FrontendModel, Cmd Types.FrontendMsg )
executeCommand model =
    let
        currentBook =
            model.currentBook

        command =
            model.inputCommand

        newBook =
            executeCommand_ command currentBook
    in
    ( { model | currentBook = newBook }, Lamdera.sendToBackend (Types.SaveNotebook newBook) )


executeCommand_ : String -> Notebook.Book.Book -> Notebook.Book.Book
executeCommand_ command book =
    case P.run commandParser command of
        Ok (RemoveCells from to) ->
            let
                _ =
                    Debug.log "__(from, to)" ( from, to )

                cells =
                    book.cells

                _ =
                    Debug.log "__Old length" (List.length cells)

                newCells =
                    cells
                        |> removeSegment (from - 1) (to - 1)
                        |> List.indexedMap (\n cell -> { cell | index = n })
            in
            { book | cells = newCells }

        Err _ ->
            book


removeSegment : Int -> Int -> List a -> List a
removeSegment from to list =
    List.take from list ++ List.drop (to + 1) list


slice : Int -> Int -> List a -> List a
slice from to list =
    list |> List.take (to + 1) |> List.drop from


commandParser =
    P.oneOf [ removeCodeParser ]


removeCodeParser =
    P.succeed (\from to -> RemoveCells from to)
        |. P.symbol "removeCells"
        |. P.spaces
        |= P.int
        |. P.spaces
        |= P.int
