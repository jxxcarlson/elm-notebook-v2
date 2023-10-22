module Notebook.Parser exposing
    ( Classification(..)
    , classify
    , getErrorItem
    , getErrorItemLength
    , getErrorOffset
    , getLineNumberAnnotation
    , getPrefixTillBacktick
    , getPrefixTillBar
    , numberOfLeadingSpaces
    , replItemParser
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
        , int
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


getPrefixTillBar : String -> Maybe String
getPrefixTillBar str =
    case run getPrefixTillBarParser str of
        Ok prefix ->
            Just prefix

        Err _ ->
            Nothing


getLineNumberAnnotation : String -> Maybe String
getLineNumberAnnotation str =
    case run lineNumberAnnotationParser str of
        Ok prefix ->
            Just prefix

        Err _ ->
            Nothing


lineNumberAnnotationParser : Parser String
lineNumberAnnotationParser =
    succeed (\a b src -> String.slice a b src)
        |. chompUntil "\n\n"
        |= getOffset
        |. symbol "\n\n"
        |. int
        |. symbol "|"
        |= getOffset
        |= getSource


getPrefixTillBarParser : Parser String
getPrefixTillBarParser =
    succeed (\a b src -> String.slice a b src)
        |= getOffset
        |. chompUntil "|"
        |. symbol "|"
        |= getOffset
        |= getSource


getErrorItemLength : Parser Int
getErrorItemLength =
    succeed identity
        |. chompUntil "``"
        |. symbol "`"
        |= getOffset
        |. chompUntil "``"
        |. symbol "`"


getErrorItem : String -> Maybe String
getErrorItem str =
    case run getErrorItemParser str of
        Ok prefix ->
            Just prefix

        Err _ ->
            Nothing


getErrorItemParser : Parser String
getErrorItemParser =
    succeed (\a b src -> String.slice a b src)
        |. chompUntil "`"
        |. symbol "`"
        |= getOffset
        |. chompUntil "`"
        |= getOffset
        |= getSource


getPrefixTillBacktick : String -> Maybe String
getPrefixTillBacktick str =
    case run getPrefixTillBacktickParser str of
        Ok prefix ->
            Just prefix

        Err _ ->
            Nothing


getPrefixTillBacktickParser : Parser String
getPrefixTillBacktickParser =
    succeed (\a b src -> String.slice a b src)
        |= getOffset
        |. chompUntil "`"
        |. symbol "`"
        |= getOffset
        |= getSource


errorOffsetParser : Parser Int
errorOffsetParser =
    succeed identity
        |. chompUntil "\n\n"
        |. symbol "\n\n"
        |= Parser.int
        |. symbol "|"


numberOfLeadingSpaces : String -> Int
numberOfLeadingSpaces str =
    case run leadingSpaceParser str of
        Ok offset ->
            offset

        Err _ ->
            0


leadingSpaceParser : Parser Int
leadingSpaceParser =
    succeed identity
        |. chompWhile (\c -> c == ' ')
        |= getOffset


type Classification
    = Expr String
    | Decl String String
    | Import String String
    | TypeAlias String String
    | ElmType String String


resolve : ( String, String ) -> Classification
resolve ( lhs, rhs ) =
    if String.left 1 rhs == "=" then
        Expr (lhs ++ " =" ++ rhs)

    else if String.left 1 lhs == "{" then
        Expr (lhs ++ " = " ++ rhs)

    else if String.contains "type alias" lhs then
        TypeAlias (String.replace "type alias" "" lhs |> String.trim) rhs

    else if String.contains "type" lhs then
        ElmType (String.replace "type" "" lhs |> String.trim) rhs

    else if String.contains "import" lhs then
        Import lhs rhs

    else
        Decl lhs rhs


lhsRhsParser : Parser Classification
lhsRhsParser =
    succeed
        (\a1 a2 b1 b2 source ->
            ( String.slice a1 a2 source |> String.trim, String.slice b1 b2 source |> String.trim ) |> resolve
        )
        |= getOffset
        |. chompWhile (\c -> c /= '=')
        |= getOffset
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
    Parser.oneOf
        [ importParser
        , Parser.backtrackable lhsRhsParser
        , expressionParser
        ]


classify : String -> Result (List Parser.DeadEnd) Classification
classify str =
    run replItemParser str
