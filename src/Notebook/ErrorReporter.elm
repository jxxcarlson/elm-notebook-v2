module Notebook.ErrorReporter exposing
    ( collateErrorReports
    , decodeErrorReporter
    , errorKeys
    , errorsToString
    , prepareReport
    , stringToMessageItem
    )

{-| This module contains the decoders for the error messages that the repl
-}

import Element exposing (..)
import Element.Font as Font
import Json.Decode as D
import List.Extra
import Notebook.Cell exposing (Cell)
import Notebook.Parser
import Notebook.Types exposing (MessageItem(..), StyledString)
import View.Style


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


errorSummary : List Cell -> List ( Int, Element msg )
errorSummary cells =
    case collateErrorReports cells of
        [] ->
            []

        errors ->
            List.map (prepareReport 0 >> (\( k, xx ) -> ( k, Element.column [] xx ))) errors



--prepareReport : Int -> ( Int, List MessageItem ) -> ( Int, List (Element msg) )
--prepareReport errorOffset ( k, items_ )


collateErrorReports : List Cell -> List ( Int, List Notebook.Types.MessageItem )
collateErrorReports cells =
    let
        foo c =
            case c.report of
                Nothing ->
                    Nothing

                Just report ->
                    Just ( c.index, report )

        collatedData =
            cells
                |> List.map (\c -> foo c)
                |> List.filterMap identity
                |> Debug.log "___collatedData"
    in
    collatedData


errorsToString : List Cell -> String
errorsToString cells =
    cells
        |> List.map .report
        |> List.filterMap identity
        |> List.Extra.uniqueBy (List.map Notebook.Types.toString)
        |> List.map (List.map Notebook.Types.toString >> String.join "\n")
        |> String.join "\n\n"


errorsToStringListList : List { a | report : Maybe (List MessageItem) } -> List (List String)
errorsToStringListList cells =
    cells
        |> List.map .report
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
            -- el [] (text (str |> String.replace "\n" ""))
            el [] (text str)

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

                padding_ =
                    if String.contains "^" styledString.string then
                        paddingXY 15 8

                    else
                        paddingXY 8 8
            in
            el [ padding_, Font.color color, style ] (text styledString.string)


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


adjustErrorLocation : MessageItem -> MessageItem
adjustErrorLocation messageItem =
    case messageItem of
        Plain str ->
            case Notebook.Parser.getErrorOffset str of
                Nothing ->
                    messageItem

                Just offset ->
                    let
                        target =
                            String.fromInt offset ++ "|"

                        replacement =
                            -- String.fromInt (offset - errorOffset) ++ "| "
                            ""
                    in
                    Plain (String.replace target replacement str)

        Styled _ ->
            messageItem


messageItemFilter : String -> MessageItem -> Bool
messageItemFilter key item =
    case item of
        Plain str ->
            not <| String.contains key str

        Styled styledString ->
            not <| String.contains key styledString.string



--collateErrorReports : List Cell -> List ( Int, List Notebook.Types.MessageItem )
--collateErrorReports cells


prepareReport : Int -> ( Int, List MessageItem ) -> ( Int, List (Element msg) )
prepareReport errorOffset ( k, items_ ) =
    let
        items =
            items_
                |> List.filter (messageItemFilter "Evergreen")
                |> List.map (adjustErrorLocation errorOffset)

        groups : List (List MessageItem)
        groups =
            groupMessageItemsHelp (breakMessages items)

        bar : List (Element msg)
        bar =
            groups
                |> List.map (List.map (\item -> renderMessageItem item))
                |> List.map (\group_ -> paragraph [] group_)
    in
    ( k, bar )


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
