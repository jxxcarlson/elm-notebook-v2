module Notebook.Parser exposing
    ( Classification(..)
    , classify
    , expressionParser
    , getErrorOffset
    , replItemParser
    , typeAliasParser
    )

import Parser
    exposing
        ( (|.)
        , (|=)
        , Parser
        , chompUntil
        , chompUntilEndOr
        , chompWhile
        , getChompedString
        , getOffset
        , getSource
        , run
        , spaces
        , succeed
        , symbol
        )


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
    | Import String String
    | TypeAlias String String
    | ElmType String String


declarationsParser : Parser Classification
declarationsParser =
    succeed (\a1 a2 b1 b2 source -> Decl (String.slice a1 a2 source |> String.trim) (String.slice b1 b2 source))
        |= getOffset
        |. chompWhile (\c -> c /= '=')
        |= getOffset
        |. spaces
        |. symbol "="
        |. spaces
        |= getOffset
        |. chompUntilEndOr "\n\n"
        |= getOffset
        |= getSource


typeAliasParser : Parser Classification
typeAliasParser =
    succeed (\a1 a2 b1 b2 source -> TypeAlias (String.slice a1 a2 source |> String.trim) (String.slice b1 b2 source))
        |. symbol "type alias "
        |= getOffset
        |. chompWhile (\c -> c /= ' ')
        |= getOffset
        |. spaces
        |. symbol "="
        |. spaces
        |= getOffset
        |. chompUntilEndOr "\n\n"
        |= getOffset
        |= getSource


elmTypeParser : Parser Classification
elmTypeParser =
    succeed (\a1 a2 b1 b2 source -> ElmType (String.slice a1 a2 source |> String.trim) (String.slice b1 b2 source))
        |. symbol "type "
        |= getOffset
        |. chompWhile (\c -> c /= ' ')
        |= getOffset
        |. spaces
        |. symbol "="
        |. spaces
        |= getOffset
        |. chompUntilEndOr "\n\n"
        |= getOffset
        |= getSource


expressionParser : Parser Classification
expressionParser =
    chompUntilEndOr "\n\n"
        |> getChompedString
        |> Parser.map (\s -> Expr s)


importParser : Parser Classification
importParser =
    succeed (\a1 a2 b1 b2 source -> Import (String.slice a1 a2 source |> String.trim) (String.slice b1 b2 source))
        |. symbol "import "
        |= getOffset
        |. chompWhile (\c -> c /= ' ')
        |= getOffset
        |. spaces
        |= getOffset
        |. chompUntilEndOr "\n\n"
        |= getOffset
        |= getSource


replItemParser =
    Parser.oneOf [ importParser, typeAliasParser, elmTypeParser, Parser.backtrackable declarationsParser, expressionParser ]


classify : String -> Result (List Parser.DeadEnd) Classification
classify str =
    run replItemParser str
