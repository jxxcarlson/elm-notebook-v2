module Notebook.Eval exposing
    ( displayDictionary
    , encodeExpr
    , hasReplError
    , initEmptyEvalState
    , insertDeclaration
    , insertImport
    , insertTypeDeclaration
    , removeDeclaration
    , replDataCodec
    , replErrorOffset
    , reportError
    , requestEvaluation
    , requestEvaluationAsTask
    , updateEvalStateWithPackages
    )

import Codec exposing (Codec, Value)
import Dict exposing (Dict)
import Element as E exposing (Element)
import Element.Font as Font
import Env exposing (Mode(..))
import Http
import Json.Encode as Encode
import Notebook.Cell exposing (Cell)
import Notebook.ErrorReporter as ErrorReporter
import Notebook.Types exposing (EvalState, MessageItem(..), ReplData)
import Task exposing (Task)
import Types exposing (FrontendMsg)
import Util
import View.Geometry


replDataCodec : Codec ReplData
replDataCodec =
    Codec.object ReplData
        |> Codec.field "name" .name (Codec.maybe Codec.string)
        |> Codec.field "value" .value Codec.string
        |> Codec.field "type" .tipe Codec.string
        |> Codec.buildObject


updateEvalStateWithPackages : Dict String Notebook.Types.ElmPackageSummary -> EvalState -> EvalState
updateEvalStateWithPackages packageSummary evalState =
    let
        exposedModules : List String
        exposedModules =
            Dict.values packageSummary
                |> List.map .exposedModules
                |> List.concat

        imports =
            exposedModules
                |> List.map (\name -> ( name, "import " ++ name ++ "\n" ))
                |> Dict.fromList
    in
    { decls = evalState.decls
    , types = Dict.empty
    , imports = imports
    }


requestEvaluation : EvalState -> Cell -> String -> Cmd FrontendMsg
requestEvaluation evalState cell expr =
    Http.post
        { url =
            case Env.mode of
                Production ->
                    "https://repl.lamdera.com/repl"

                Development ->
                    "http://localhost:8000/repl"
        , body = Http.jsonBody (encodeExpr evalState expr)
        , expect = Http.expectString (Types.GotReplyFromCompiler cell)
        }


requestEvaluationAsTask : EvalState -> String -> Task Http.Error String
requestEvaluationAsTask evalState expr =
    Http.task
        { method = "POST"
        , headers = []
        , url =
            case Env.mode of
                Production ->
                    "https://repl.lamdera.com/repl"

                Development ->
                    "http://localhost:8000/repl"
        , body = Http.jsonBody (encodeExpr evalState expr)

        -- , expect = Http.expectString identity
        , resolver = Http.stringResolver stringResolverToResult
        , timeout = Nothing
        }



-- Helper function


stringResolverToResult : Http.Response String -> Result Http.Error String
stringResolverToResult response =
    case response of
        Http.BadUrl_ url ->
            Err (Http.BadUrl url)

        Http.Timeout_ ->
            Err Http.Timeout

        Http.NetworkError_ ->
            Err Http.NetworkError

        Http.BadStatus_ metadata body ->
            Err (Http.BadStatus metadata.statusCode)

        Http.GoodStatus_ metadata body ->
            Ok body


dictionaryLines : Dict String String -> Int
dictionaryLines dict =
    dict |> Dict.values |> String.join "" |> String.split "\n" |> List.length


replErrorOffset : Dict String String -> Int
replErrorOffset dict =
    dictionaryLines dict + 1


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


insertImport : String -> String -> EvalState -> EvalState
insertImport name value evalState =
    { evalState
        | imports =
            Dict.insert (String.trim name) value evalState.imports
    }


insertTypeDeclaration : String -> String -> EvalState -> EvalState
insertTypeDeclaration name value evalState =
    { evalState
        | types =
            Dict.insert (String.trim name) value evalState.types
    }


displayDictionary : Types.FrontendModel -> Dict String String -> Element msg
displayDictionary model declarationDict =
    E.column
        [ E.spacing 24
        , Font.size 14
        , E.height (E.px (View.Geometry.bodyHeight model))
        , E.paddingEach { left = 18, right = 0, top = 0, bottom = 0 }
        ]
        (List.map
            (\( k, v ) -> displayValue ( k, v ))
            (Dict.toList declarationDict)
        )


displayValue : ( String, String ) -> Element msg
displayValue ( k, v ) =
    E.column [ E.width E.fill, E.spacing 8 ]
        (List.map E.text (String.lines v))


initEmptyEvalState : EvalState
initEmptyEvalState =
    { decls = Dict.empty
    , types = Dict.empty
    , imports = Dict.empty
    }


encodeExpr : EvalState -> String -> Encode.Value
encodeExpr evalState expr =
    let
        _ =
            Debug.log "@@imports" evalState.imports

        _ =
            Debug.log "@@types" evalState.types

        _ =
            Debug.log "@@decls" evalState.decls
    in
    Encode.object
        [ ( "entry", Encode.string (expr |> removeComments |> String.replace "\n" " " |> Util.compressSpaces |> (\x -> x ++ "\n")) )
        , ( "imports", Encode.dict identity Encode.string evalState.imports )
        , ( "types", Encode.dict identity Encode.string evalState.types )
        , ( "decls", Encode.dict identity Encode.string evalState.decls )
        ]


removeComments : String -> String
removeComments str =
    str |> String.lines |> List.filter (\line -> String.left 2 line /= "--") |> String.join "\n"


reportError : String -> List MessageItem
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
    [ Plain <| "Unknown REPL error" ]
