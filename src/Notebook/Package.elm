module Notebook.Package exposing (..)

import Dict exposing (Dict)
import Env exposing (Mode(..))
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipeline exposing (required)
import Notebook.Codec
import Notebook.Types exposing (SimplePackageInfo)
import Process
import Task
import Types


{-| This function talks to the Elm compiler via

    Endpoint.Package.handlePost :: Snap ()

-}
sendPackageList : Notebook.Types.PackageList -> Cmd Types.FrontendMsg
sendPackageList packageList =
    Http.post
        { url =
            case Env.mode of
                Production ->
                    "https://repl.lamdera.com/packageList"

                Development ->
                    "http://localhost:8000/packageList"
        , body = Http.jsonBody (Notebook.Codec.encodePackageList packageList)
        , expect = Http.expectString Types.PackageListSent
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


makePackageList : Types.FrontendModel -> List String
makePackageList model =
    model.inputPackages
        |> String.trim
        |> String.lines


nowSendPackageList : Types.FrontendModel -> ( Types.FrontendModel, Cmd Types.FrontendMsg )
nowSendPackageList model =
    let
        packages : List { name : String, version : String }
        packages =
            model.packageDict
                |> Dict.values
                |> List.map (\value -> { name = value.name, version = value.version })
    in
    ( model, sendPackageList packages )


updateElmJsonDependencies : Types.FrontendModel -> ( Types.FrontendModel, Cmd Types.FrontendMsg )
updateElmJsonDependencies model =
    let
        packageList : List String
        packageList =
            makePackageList model

        n =
            packageList |> List.length

        indices =
            List.range 0 (n - 1)

        commands =
            List.map2 (\packageItem idx -> createDelayedCommand packageItem idx) packageList indices

        delayInMs =
            (n + 1) * 50 |> toFloat

        delayCmd =
            Process.sleep delayInMs |> Task.perform (always Types.ExecuteDelayedFunction)
    in
    ( model, Cmd.batch <| delayCmd :: commands )


createDelayedCommand packageItem idx =
    Process.sleep (toFloat (idx * 50))
        |> Task.perform (\_ -> Types.FetchDependencies packageItem)


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


exposedModulesDecoder : Decoder (List String)
exposedModulesDecoder =
    Decode.field "exposed-modules" (Decode.list Decode.string)


elmPackageSummaryDecoder : Decoder Notebook.Types.ElmPackageSummary
elmPackageSummaryDecoder =
    Decode.succeed Notebook.Types.ElmPackageSummary
        |> required "dependencies" (Decode.dict Decode.string)
        |> required "exposed-modules" (Decode.list Decode.string)
        |> required "name" Decode.string
        |> required "version" Decode.string


requestPackagesFromCompiler : Cmd Types.FrontendMsg
requestPackagesFromCompiler =
    Http.post
        { url =
            case Env.mode of
                Production ->
                    "https://repl.lamdera.com/reportOnInstalledPackages"

                Development ->
                    "http://localhost:8000/reportOnInstalledPackages"
        , body = Http.emptyBody
        , expect = Http.expectJson Types.GotPackagesFromCompiler simplePackageListDecoder
        }


{-| ["{"name": "zwilias/elm-rosetree", "version": "1.5.0"}","{"name": "elm-community/maybe-extra", "version": "5.3.0"}","{"name": "elm/core", "version": "1.0.5"}","{"name": "elm-community/list-extra", "version": "8.7.0"}"]
-}
simplePackageListDecoder : Decoder (List SimplePackageInfo)
simplePackageListDecoder =
    Decode.list simplePackageInfoDecoder


simplePackageInfoDecoder : Decoder SimplePackageInfo
simplePackageInfoDecoder =
    Decode.succeed SimplePackageInfo
        |> required "name" Decode.string
        |> required "version" Decode.string
