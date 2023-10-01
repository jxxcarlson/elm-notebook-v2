module Notebook.Parser exposing (Classification(..), classify, getErrorOffset)

import Parser exposing ((|.), (|=), Parser, chompUntil, chompWhile, getChompedString, run, succeed, symbol)


prefix : Parser String
prefix =
    getChompedString <|
        succeed ()
            |. chompWhile (\c -> c /= '=')
            |. symbol "= "


getErrorOffset : String -> Maybe Int
getErrorOffset str =
    case run errorOffsetParser str of
        Ok offset ->
            Just offset

        Err _ ->
            Nothing


errorOffsetParser : Parser Int
errorOffsetParser =
    succeed identity
        |. chompUntil "\n\n"
        |. symbol "\n\n"
        |= Parser.int
        |. symbol "|"


type Classification
    = Expr String
    | Decl String String


classify : String -> Classification
classify str =
    case run prefix str of
        Ok str2 ->
            Decl (String.replace "= " "" str2 |> String.trim) (String.replace str2 "" str)

        Err _ ->
            Expr str
