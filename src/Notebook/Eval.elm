module Notebook.Eval exposing
    ( displayDictionary
    , encodeExpr
    , hasReplError
    , initEmptyEvalState
    , initEvalState
    , insertDeclaration
    , removeDeclaration
    , replDataCodec
    , reportError
    , requestEvaluation
    )

import Codec exposing (Codec, Value)
import Dict exposing (Dict)
import Element as E exposing (Element)
import Element.Font as Font
import Http
import Json.Encode as Encode
import Notebook.ErrorReporter as ErrorReporter
import Notebook.Types exposing (EvalState, ReplData)
import Types exposing (FrontendMsg)


replDataCodec : Codec ReplData
replDataCodec =
    Codec.object ReplData
        |> Codec.field "name" .name (Codec.maybe Codec.string)
        |> Codec.field "value" .value Codec.string
        |> Codec.field "type" .tipe Codec.string
        |> Codec.buildObject


requestEvaluation : EvalState -> String -> Cmd FrontendMsg
requestEvaluation evalState expr =
    Http.post
        { url = "http://localhost:8000/repl"
        , body = Http.jsonBody (encodeExpr evalState expr)
        , expect = Http.expectString Types.GotReply
        }


insertDeclaration : String -> String -> EvalState -> EvalState
insertDeclaration name value evalState =
    { evalState
        | decls =
            Dict.insert (String.trim name) value evalState.decls
    }


removeDeclaration : String -> EvalState -> EvalState
removeDeclaration name evalState =
    { evalState
        | decls =
            Dict.remove name evalState.decls
    }


displayDictionary : Dict String String -> Element msg
displayDictionary declarationDict =
    E.column [ E.spacing 12, Font.size 14 ]
        (List.map
            (\( k, v ) -> displayValue ( k, v ))
            (Dict.toList declarationDict |> List.sortBy Tuple.first)
        )


displayValue : ( String, String ) -> Element msg
displayValue ( k, v ) =
    E.el [ E.width E.fill ] (E.text v)


displayItem : ( String, String ) -> Element msg
displayItem ( k, v ) =
    E.row [ E.spacing 12 ]
        [ E.el [ E.width (E.px 100) ] (E.text k)
        , E.el [ E.width (E.px 400) ] (E.text v)
        ]


initEvalState : EvalState
initEvalState =
    { decls =
        Dict.fromList
            [ ( "inc", "inc x = x + 1\n" )
            , ( "foo", "foo = 123\n" )
            , ( "bar", "bar = 456\n" )
            ]
    , types = Dict.fromList []
    , imports = Dict.fromList [ ( "elm-community/list-extra", "import List.Extra\n" ) ]
    }


initEmptyEvalState : EvalState
initEmptyEvalState =
    { decls = Dict.empty
    , types = Dict.empty
    , imports = Dict.empty
    }


encodeExpr : EvalState -> String -> Encode.Value
encodeExpr evalState expr =
    Encode.object
        [ ( "entry", Encode.string expr )
        , ( "imports", Encode.dict identity Encode.string evalState.imports )
        , ( "types", Encode.dict identity Encode.string evalState.types )
        , ( "decls", Encode.dict identity Encode.string evalState.decls )
        ]


reportError : String -> List ErrorReporter.MessageItem
reportError str =
    case ErrorReporter.decodeErrorReporter str of
        Ok replError ->
            renderReplError replError

        Err _ ->
            unknownReplError str


hasReplError : String -> Bool
hasReplError str =
    String.left 24 str == "{\"type\":\"compile-errors\""


renderReplError : { a | errors : List { b | problems : List { c | message : List d } } } -> List d
renderReplError replError =
    replError
        |> .errors
        |> List.concatMap .problems
        |> List.concatMap .message


unknownReplError str =
    [ ErrorReporter.Plain <| "Unknown REPL error" ]
