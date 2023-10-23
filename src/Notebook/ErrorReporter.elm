module Notebook.ErrorReporter exposing
    ( RenderedErrorReport
    , collateErrorReports
    , compress
    , decodeErrorReporter
    , errorKeys
    , errorKeysFromCells
    , errorsToString
    , pairUp
    , renderReport
    , stringToMessageItem
    )

{-| This module contains the decoders for the error messages that the repl
-}

import Element exposing (..)
import Element.Font as Font
import Html.Attributes
import Json.Decode as D
import List.Extra
import Notebook.Cell exposing (Cell)
import Notebook.Parser
import Notebook.RepeatingBlocks
import Notebook.Types exposing (ErrorReport, MessageItem(..), StyledString)
import Types
import View.Style
import View.Utility


type alias RenderedErrorReport =
    ( Int, List (Element Types.FrontendMsg) )


type alias ReplError =
    { tipe : String
    , errors : List ErrorItem
    }


type alias ErrorItem =
    { path : String
    , name : String
    , problems : List Problem
    }


type alias Region =
    { start : Position
    , end : Position
    }


type alias Position =
    { line : Int
    , column : Int
    }


type alias Problem =
    { title : String
    , region : Region
    , message : List MessageItem
    }


errorKeysFromCells : List Cell -> List ( List Int, String )
errorKeysFromCells cells =
    errorKeys cells
        |> List.map (String.split "|")
        |> List.map (List.Extra.getAt 1)
        |> List.filterMap identity
        |> List.map String.trim
        |> List.Extra.unique
        |> List.map (\s -> ( Notebook.Cell.locate s cells, s ))
        |> List.sortBy (\( loc, _ ) -> loc)
        |> Debug.log "@@@@errorKeysFromCells"


errorSummary : List Cell -> List ( Int, Element Types.FrontendMsg )
errorSummary cells =
    case collateErrorReports cells of
        [] ->
            []

        errors ->
            List.map (renderReport >> (\( k, xx ) -> ( k, Element.column [] xx ))) errors |> Debug.log "@@@@errorSummary"



--               |> List.map Notebook.RepeatingBlocks.removeLineNumberAnnotation


removeLineNumberAnnotations : ErrorReport -> ErrorReport
removeLineNumberAnnotations ( k, items ) =
    ( k, List.map Notebook.RepeatingBlocks.removeLineNumberAnnotation items )


compress : List MessageItem -> List MessageItem
compress =
    Notebook.RepeatingBlocks.removeOneRepeatingBlock (\a b -> Notebook.Types.toString a == Notebook.Types.toString b)


collateErrorReports : List Cell -> List ErrorReport
collateErrorReports cells =
    let
        extractErrorReport : Cell -> Maybe ErrorReport
        extractErrorReport c =
            case c.report of
                ( _, Nothing ) ->
                    Nothing

                ( index, Just report ) ->
                    Just ( index, report )

        collatedData : List ErrorReport
        collatedData =
            cells
                |> List.map (\c -> extractErrorReport c)
                |> List.filterMap identity
                |> List.map removeLineNumberAnnotations
                |> List.map (\( k, r ) -> ( k, List.filter (messageItemFilter "Evergreen") r ))
                |> List.map (\( k, r ) -> ( k, fixTrailingSpaces r ))
                -- Below: flag duplicates
                |> List.foldl (\( index, report ) acc -> addOrReferenceBack ( index, report ) acc) []

        -- |> Debug.log "@@@@collatedData"
        --|> List.map compress
        compressReport : ( Int, List MessageItem ) -> ( Int, List MessageItem )
        compressReport ( k, list ) =
            ( k, Notebook.RepeatingBlocks.removeOneRepeatingBlock (\a b -> Notebook.Types.toString a == Notebook.Types.toString b) list )

        --|> List.map (\( k, r ) -> ( k, compressor (r |> Debug.log "RRRR") ))
        --|> Notebook.RepeatingBlocks.removeOneRepeatingBlock (\a b -> Tuple.second a == Tuple.second b)
        addOrReferenceBack : ErrorReport -> List ErrorReport -> List ErrorReport
        addOrReferenceBack ( index, rawReport ) acc_ =
            case List.Extra.find (\( _, rawReport_ ) -> rawReport_ == rawReport) acc_ of
                Nothing ->
                    ( index, rawReport ) :: acc_

                Just ( idx, _ ) ->
                    let
                        messageItem : MessageItem
                        messageItem =
                            Styled { bold = False, underline = False, color = Just "yellow", string = "Duplicate error, see cell " ++ String.fromInt (idx + 1) }
                    in
                    ( index, [ messageItem ] ) :: acc_
    in
    List.reverse collatedData


pairUp : List a -> List ( a, a )
pairUp items =
    case items of
        [] ->
            []

        first :: second :: rest ->
            ( first, second ) :: pairUp rest

        _ ->
            []


fixTrailingSpaces : List MessageItem -> List MessageItem
fixTrailingSpaces items =
    items
        |> pairUp
        |> List.map moveTrailingSpace
        |> List.concat


moveTrailingSpace : ( MessageItem, MessageItem ) -> List MessageItem
moveTrailingSpace ( first, second ) =
    let
        spacer =
            ""
    in
    case ( first, second ) of
        ( Plain str, Styled styledString ) ->
            case Notebook.Parser.getTrailingSpaces str of
                Nothing ->
                    [ first, second ]

                Just trailingSpaces ->
                    [ Plain str, Styled { styledString | string = String.dropLeft 1 trailingSpaces ++ spacer ++ styledString.string } ]

        _ ->
            [ first, second ]


errorsToString : List Cell -> String
errorsToString cells =
    cells
        |> List.map (.report >> Tuple.second)
        |> List.filterMap identity
        |> List.Extra.uniqueBy (List.map Notebook.Types.toString)
        |> List.map (List.map Notebook.Types.toString >> String.join "\n")
        |> String.join "\n\n"


errorsToStringListList : List Cell -> List (List String)
errorsToStringListList cells =
    cells
        |> List.map (.report >> Tuple.second)
        |> List.filterMap identity
        |> List.Extra.uniqueBy (List.map Notebook.Types.toString)
        |> List.map (List.map Notebook.Types.toString)


errorKeys : List Cell -> List String
errorKeys cells =
    errorsToStringListList cells
        |> List.concat
        |> List.filter (\item -> String.contains "|" item)


renderMessageItem : MessageItem -> Element msg
renderMessageItem messageItem =
    case messageItem of
        Plain str ->
            if isBlank str then
                Element.none

            else
                el [ View.Style.monospace ] (View.Utility.preformattedElement [] (Debug.log "@@S" str))

        Styled styledString ->
            let
                color =
                    if String.contains "^" styledString.string then
                        Element.rgb 1.0 0 0

                    else
                        case styledString.color of
                            Nothing ->
                                Element.rgb 0.9 0 0.6

                            Just "red" ->
                                Element.rgb 1 0 0

                            Just "green" ->
                                Element.rgb 0 1 0

                            Just "blue" ->
                                Element.rgb 0 0 1

                            Just "yellow" ->
                                Element.rgb 1 1 0

                            Just "black" ->
                                Element.rgb 0.9 0.4 0.1

                            Just "white" ->
                                Element.rgb 1 1 1

                            _ ->
                                Element.rgb 0 1 0

                style =
                    if styledString.bold then
                        Font.bold

                    else if styledString.underline then
                        Font.underline

                    else
                        Font.unitalicized
            in
            el [ Font.color color, style, View.Style.monospace ] (View.Utility.preformattedElement [] (Debug.log "@@SS" styledString.string))


isBlank : String -> Bool
isBlank str =
    (str |> String.replace "\n" "" |> String.trim) == ""


stringToMessageItem : String -> MessageItem
stringToMessageItem str =
    Plain str


decodeErrorReporter str =
    D.decodeString replErrorDecoder str


replErrorDecoder : D.Decoder ReplError
replErrorDecoder =
    D.map2 ReplError
        (D.field "type" D.string)
        (D.field "errors" (D.list errorItemDecoder))


errorItemDecoder : D.Decoder ErrorItem
errorItemDecoder =
    D.map3 ErrorItem
        (D.field "path" D.string)
        (D.field "name" D.string)
        (D.field "problems" (D.list problemDecoder))


problemDecoder : D.Decoder Problem
problemDecoder =
    D.map3 Problem
        (D.field "title" D.string)
        (D.field "region" regionDecoder)
        (D.field "message" (D.list messageItemDecoder))


regionDecoder : D.Decoder Region
regionDecoder =
    D.map2 Region
        (D.field "start" positionDecoder)
        (D.field "end" positionDecoder)


positionDecoder : D.Decoder Position
positionDecoder =
    D.map2 Position
        (D.field "line" D.int)
        (D.field "column" D.int)


messageItemDecoder : D.Decoder MessageItem
messageItemDecoder =
    D.oneOf
        [ D.map Plain D.string
        , D.map Styled styledStringDecoder
        ]


styledStringDecoder : D.Decoder StyledString
styledStringDecoder =
    D.map4 StyledString
        (D.field "bold" D.bool)
        (D.field "underline" D.bool)
        (D.field "color" (D.nullable D.string))
        (D.field "string" D.string)


breakMessage : MessageItem -> List MessageItem
breakMessage messageItem =
    case messageItem of
        Plain str ->
            let
                parts =
                    String.split "\n" str

                n =
                    List.length parts

                prefix =
                    List.take (n - 1) parts |> List.map (\str_ -> Plain (str_ ++ "\n"))

                last =
                    List.drop (n - 1) parts |> List.map (\str_ -> Plain str_)
            in
            prefix ++ last

        Styled styledString ->
            [ Styled styledString ]


breakMessages : List MessageItem -> List MessageItem
breakMessages messageItems =
    messageItems
        |> List.map breakMessage
        |> List.concat


err =
    [ Plain "The (++) operator can append List and String values, but not "
    , Styled { bold = False, color = Just "yellow", string = "number", underline = False }
    , Plain " values like\nthis:\n\n7|   1 ++ 1\n     "
    , Styled { bold = False, color = Just "RED", string = "^", underline = False }
    , Plain "\nTry using "
    , Styled { bold = False, color = Just "GREEN", string = "String.fromInt", underline = False }
    , Plain " to turn it into a string? Or put it in [] to make it a\nlist? Or switch to the (::) operator?"
    ]


messageItemFilter : String -> MessageItem -> Bool
messageItemFilter key item =
    case item of
        Plain str ->
            not <| String.contains key str

        Styled styledString ->
            not <| String.contains key styledString.string


renderReport : ErrorReport -> RenderedErrorReport
renderReport ( k, items__ ) =
    let
        items_ =
            List.map Notebook.RepeatingBlocks.removeLineNumberAnnotation items__
    in
    ( k, List.map renderMessageItem items_ )


renderReport1 : ErrorReport -> RenderedErrorReport
renderReport1 ( k, items__ ) =
    let
        items_ =
            List.map Notebook.RepeatingBlocks.removeLineNumberAnnotation items__
    in
    case items_ of
        first_ :: second_ :: rest ->
            let
                stringInFirstItem =
                    case first_ of
                        Notebook.Types.Plain str_ ->
                            str_

                        _ ->
                            "NADA"

                foo =
                    case String.split "\n\n" stringInFirstItem of
                        [ _, b ] ->
                            b

                        _ ->
                            stringInFirstItem

                mErrorItem =
                    Notebook.Parser.getErrorItem stringInFirstItem

                offset =
                    case mErrorItem of
                        Nothing ->
                            0

                        Just errorItem ->
                            String.indices errorItem foo
                                |> List.head
                                |> Maybe.withDefault 0
                                |> (\x -> max (x - 2) 0)

                first =
                    first_

                second =
                    case second_ of
                        Plain _ ->
                            second_

                        Styled styledString ->
                            Styled { styledString | string = String.repeat offset " " ++ styledString.string }

                items =
                    rest
                        |> List.filter (messageItemFilter "Evergreen")

                groups : List (List MessageItem)
                groups =
                    groupMessageItemsHelp (breakMessages (Notebook.RepeatingBlocks.removeLineNumberAnnotation first :: second :: items))

                bar : List (Element msg)
                bar =
                    groups
                        |> List.map (List.map (\item -> renderMessageItem item))
                        |> List.map (\group_ -> paragraph [] group_)
            in
            ( k, bar )

        _ ->
            ( k, [] )


groupMessageItemsHelp : List MessageItem -> List (List MessageItem)
groupMessageItemsHelp messageItems =
    List.Extra.groupWhile grouper messageItems |> List.map (\( first, rest ) -> first :: rest)


{-| start new group on false
-}
grouper : MessageItem -> MessageItem -> Bool
grouper item1 item2 =
    case ( item1, item2 ) of
        ( Plain str, _ ) ->
            not <| String.contains "\n" str

        ( Styled _, _ ) ->
            True
