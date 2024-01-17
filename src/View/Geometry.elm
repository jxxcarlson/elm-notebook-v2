module View.Geometry exposing
    ( appHeight
    , appWidth
    , bodyHeight
    , footerHeight
    , hPadding
    , headerHeight
    , loweRightSidePanelHeight
    , mainColumnHeight
    , notebookIndexWidth
    , notebookWidth
    , sidePanelWidth
    )

import View.Config


appWidth : { a | windowWidth : Int } -> Int
appWidth model =
    min 1400 model.windowWidth


appHeight : { a | windowHeight : number } -> number
appHeight model =
    model.windowHeight


mainColumnHeight : { a | windowHeight : number } -> number
mainColumnHeight model =
    appHeight model - headerHeight - footerHeight - 65


loweRightSidePanelHeight : { a | windowHeight : Int } -> Int
loweRightSidePanelHeight model =
    0.55 * (toFloat <| mainColumnHeight model) |> round


bodyHeight : { a | windowHeight : number } -> number
bodyHeight model =
    appHeight model - headerHeight - footerHeight


notebookWidth : { a | windowWidth : Int } -> Int
notebookWidth model =
    0.47 * toFloat (appWidth model) |> round


sidePanelWidth : { a | windowWidth : Int } -> Int
sidePanelWidth model =
    0.36 * toFloat (appWidth model) |> round


notebookIndexWidth : { a | windowWidth : Int } -> Int
notebookIndexWidth model =
    0.17 * toFloat (appWidth model) |> round


headerHeight =
    45


footerHeight =
    45


hPadding =
    18
