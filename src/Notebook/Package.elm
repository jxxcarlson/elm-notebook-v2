module Notebook.Package exposing (..)

import Dict exposing (Dict)
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import Notebook.Codec
import Notebook.Types
import Process
import Task
import Types


sendPackageList : Notebook.Types.PackageList -> Cmd Types.FrontendMsg
sendPackageList packageList =
    Http.post
        { url = "http://localhost:8000/packageList"
        , body = Http.jsonBody (Notebook.Codec.encodePackageList packageList)
        , expect = Http.expectWhatever Types.PackageListSent
        }


fetchElmJson : String -> Cmd Types.FrontendMsg
fetchElmJson package =
    let
        url =
            "https://raw.githubusercontent.com/" ++ package ++ "/master/elm.json"
    in
    Http.get
        { url = url
        , expect = Http.expectJson Types.GotElmJsonDict elmJsonDecoder
        }


elmJsonDecoder : Decoder (Dict String String)
elmJsonDecoder =
    Decode.field "dependencies" (Decode.field "direct" (Decode.dict Decode.string))


split str =
    case str |> String.split ":" of
        [ a, b ] ->
            Just { name = String.trim a, version = String.trim b }

        _ ->
            Nothing


makePackageList : Types.FrontendModel -> List { name : String, version : String }
makePackageList model =
    model.inputPackages
        |> Debug.log "Raw package list"
        |> String.trim
        |> String.lines
        |> List.filter (\line -> line /= "" && String.contains ":" line)
        |> List.map (\line -> split line)
        |> List.filterMap identity
        |> Debug.log "packageList"


updateElmJsonDependencies : Types.FrontendModel -> ( Types.FrontendModel, Cmd Types.FrontendMsg )
updateElmJsonDependencies model =
    let
        packageList =
            makePackageList model

        n =
            packageList |> List.length

        indices =
            List.range 0 n

        commands =
            List.indexedMap createDelayedCommand indices
    in
    ( model, Cmd.batch commands )


createDelayedCommand : Int -> Int -> Cmd Types.FrontendMsg
createDelayedCommand idx _ =
    Process.sleep (toFloat (idx * 50))
        |> Task.perform (\_ -> Types.FetchDependencies idx)
