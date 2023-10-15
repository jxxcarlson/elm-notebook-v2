module Notebook.Compile exposing (..)

import Env exposing (Mode(..))
import Http
import Json.Encode as Encode
import Types exposing (FrontendMsg)


requestCompilation : String -> Cmd FrontendMsg
requestCompilation programText =
    Http.post
        { url =
            case Env.mode of
                Production ->
                    "https://repl.lamdera.com/compile"

                Development ->
                    "http://localhost:8000/compile"
        , body = Http.jsonBody (Encode.string programText)
        , expect = Http.expectString Types.GotCompiledProgram
        }


testCompilation : Cmd FrontendMsg
testCompilation =
    requestCompilation programHelloWorld


programHelloWorld =
    """
import Html exposing (text)

main =
    text "Hello, World!"
"""
