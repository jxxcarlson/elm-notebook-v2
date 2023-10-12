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
    , updateEvalStateWithPackages
    )

import Codec exposing (Codec, Value)
import Dict exposing (Dict)
import Element as E exposing (Element)
import Element.Font as Font
import Http
import Json.Encode as Encode
import Notebook.Cell exposing (Cell)
import Notebook.ErrorReporter as ErrorReporter
import Notebook.Types exposing (EvalState, MessageItem(..), ReplData)
import Types exposing (FrontendMsg)
import Util


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
        |> Debug.log "EvalState"


requestEvaluation : Dict String Notebook.Types.ElmPackageSummary -> EvalState -> Cell -> String -> Cmd FrontendMsg
requestEvaluation elmJsonDependencies evalState cell expr =
    Http.post
        { -- url = "http://localhost:8000/repl"
          -- url = "http://repl.lamdera.com/api/repl"
          -- url = "http://repl.lamdera.com/api/repl"
          url = "http://localhost:8000/repl"

        -- , body = Http.jsonBody (encodeExpr (updateEvalStateWithPackages elmJsonDependencies evalState) expr)
        , body = Http.jsonBody (encodeExpr evalState expr)
        , expect = Http.expectString (Types.GotReply cell)
        }


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


displayDictionary : Dict String String -> Element msg
displayDictionary declarationDict =
    E.column [ E.spacing 12, Font.size 14, E.paddingEach { left = 18, right = 0, top = 0, bottom = 0 } ]
        (List.map
            (\( k, v ) -> displayValue ( k, v ))
            (Dict.toList declarationDict)
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


initEmptyEvalState : EvalState
initEmptyEvalState =
    { decls = Dict.empty
    , types = Dict.empty
    , imports = Dict.empty
    }


treeImport =
    Dict.fromList [ ( "Tree", "import Tree\n" ) ]


typeDict =
    Dict.fromList [ ( "type alias Point", "type alias Point = { x : Float , y : Float }\n" ) ]


encodeExpr : EvalState -> String -> Encode.Value
encodeExpr evalState expr =
    Encode.object
        [ ( "entry", Encode.string (expr |> removeComments |> String.replace "\n" " " |> Util.compressSpaces |> (\x -> x ++ "\n") |> Debug.log "ENCODE_EXPR") )
        , ( "imports", Encode.dict identity Encode.string (evalState.imports |> Debug.log "ENCODE_IMPORTS") )

        --, ( "imports", Encode.dict identity Encode.string (treeImport |> Debug.log "ENCODE_IMPORTS") )
        --, ( "types", Encode.dict identity Encode.string (evalState.types |> Debug.log "ENCODE_TYPES") )
        , ( "types", Encode.dict identity Encode.string (evalState.imports |> Debug.log "ENCODE_TYPES") )
        , ( "decls", Encode.dict identity Encode.string (evalState.decls |> Debug.log "ENCODE_DECLS") )
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
