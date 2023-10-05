module Notebook.Package exposing (..)

import Dict exposing (Dict)
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipeline exposing (required)
import List.Extra
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
        , expect = Http.expectJson Types.GotElmJsonDict elmPackageSummaryDecoder
        }


mergeDictionaries : Dict comparable b -> Dict comparable b -> Dict comparable b
mergeDictionaries dict1 dict2 =
    Dict.fromList (Dict.toList dict1 ++ Dict.toList dict2)



--- https://raw.githubusercontent.com/elm-file/master/elm.json


elmJsonDecoder : Decoder (Dict String String)
elmJsonDecoder =
    Decode.field "dependencies" (Decode.dict Decode.string)


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


updateElmJsonDependenciesAndThenSendPackageList : Types.FrontendModel -> ( Types.FrontendModel, Cmd Types.FrontendMsg )
updateElmJsonDependenciesAndThenSendPackageList model =
    let
        ( model1, cmd1 ) =
            updateElmJsonDependencies model

        packages : List { name : String, version : String }
        packages =
            model1.elmJsonDependencies
                |> Dict.values
                |> List.map .dependencies
                |> List.map Dict.toList
                |> List.concat
                |> List.Extra.uniqueBy Tuple.first
                |> List.filter (\( name, version ) -> not <| List.member name [ "elm/core", "elm/json" ])
                |> List.map (\( name, version ) -> { name = name, version = version })
                |> Debug.log "PACKAGES"

        _ =
            Debug.log "Number of packages to send" (List.length packages)
    in
    ( model1, Cmd.batch [ sendPackageList packages, cmd1 ] )


updateElmJsonDependencies : Types.FrontendModel -> ( Types.FrontendModel, Cmd Types.FrontendMsg )
updateElmJsonDependencies model =
    let
        packageList : List { name : String, version : String }
        packageList =
            makePackageList model

        n =
            packageList |> List.length

        indices =
            List.range 0 n |> Debug.log "@@indices"

        commands =
            List.map2 (\packageItem idx -> createDelayedCommand packageItem idx) packageList indices

        _ =
            Debug.log "commands" (List.length commands)
    in
    ( model, Cmd.batch commands )



-- createDelayedCommand : { name : String, version : String } -> Int -> Cmd Types.FrontendMsg


createDelayedCommand packageItem idx =
    Process.sleep (toFloat (idx * 50))
        |> Task.perform (\_ -> Types.FetchDependencies packageItem.name)


elmPackageDecoder : Decoder Notebook.Types.ElmPackage
elmPackageDecoder =
    Decode.succeed Notebook.Types.ElmPackage
        |> required "type" Decode.string
        |> required "name" Decode.string
        |> required "summary" Decode.string
        |> required "license" Decode.string
        |> required "version" Decode.string
        |> required "exposed-modules" exposedModulesDecoder
        |> required "elm-version" Decode.string
        |> required "dependencies" (Decode.dict Decode.string)
        |> required "test-dependencies" (Decode.dict Decode.string)



--- badBody = "Problem with the value at json.dependencies:\n\n    {\n        \"elm/bytes\": \"1.0.0 <= v < 2.0.0\",\n        \"elm/core\": \"1.0.1 <= v < 2.0.0\",\n        \"elm/json\": \"1.1.0 <= v < 2.0.0\",\n        \"elm/time\": \"1.0.0 <= v < 2.0.0\"\n    }\n\nExpecting an OBJECT with a field named `direct`"))
--exposedModulesDecoder : Decoder Notebook.Types.ExposedModules
--exposedModulesDecoder =
--    Decode.dict (Decode.list Decode.string)


exposedModulesDecoder : Decoder (List String)
exposedModulesDecoder =
    Decode.field "exposed-modules" (Decode.list Decode.string)


elmPackageSummaryDecoder : Decoder Notebook.Types.ElmPackageSummary
elmPackageSummaryDecoder =
    Decode.succeed Notebook.Types.ElmPackageSummary
        |> required "dependencies" (Decode.dict Decode.string)
        |> required "exposed-modules" (Decode.list Decode.string)
        |> required "name" Decode.string
