module View.Spinner exposing (view)

import Element exposing (Element)
import Html exposing (Html)
import Loading
import Types exposing (FrontendModel, FrontendMsg)


view : Loading.LoadingState -> Element FrontendMsg
view loadingState =
    let
        config =
            Loading.defaultConfig
    in
    Html.div []
        [ Loading.render
            Loading.Spinner
            -- LoaderType
            { config | color = "#ff4040" }
            -- Config
            loadingState

        -- LoadingState
        ]
        |> Element.html
