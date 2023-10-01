module Notebook.Parser exposing (Classification(..), classify)

import Parser exposing ((|.), Parser, chompWhile, getChompedString, run, succeed, symbol)


prefix : Parser String
prefix =
    getChompedString <|
        succeed ()
            --|. chompIf (\c -> c == '$')
            --|. chompIf (\c -> Char.isAlpha c || c == '_')
            |. chompWhile (\c -> c /= '=')
            |. symbol "= "


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
