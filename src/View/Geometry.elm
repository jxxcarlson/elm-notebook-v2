module View.Geometry exposing
    ( appHeight
    , appWidth
    , bodyHeight
    , footerHeight
    , hPadding
    , headerHeight
    , loweRightSidePanelHeight
    , mainColumnHeight
    , mainWidth
    , notebookWidth
    , sidePanelWidth
    )

import View.Config


appWidth : { a | windowWidth : Int } -> Int
appWidth model =
    min 1400 model.windowWidth


mainWidth : { a | windowWidth : Int } -> Int
mainWidth model =
    appWidth model - View.Config.lhSidebarWidth


appHeight : { a | windowHeight : number } -> number
appHeight model =
    model.windowHeight


mainColumnHeight : { a | windowHeight : number } -> number
mainColumnHeight model =
    appHeight model - headerHeight - footerHeight - 35


loweRightSidePanelHeight : { a | windowHeight : Int } -> Int
loweRightSidePanelHeight model =
    0.55 * (toFloat <| mainColumnHeight model) |> round


bodyHeight : { a | windowHeight : number } -> number
bodyHeight model =
    appHeight model - headerHeight - footerHeight


notebookWidth : { a | windowWidth : Int } -> Int
notebookWidth model =
    0.55 * toFloat (mainWidth model) |> round


sidePanelWidth : { a | windowWidth : Int } -> Int
sidePanelWidth model =
    0.45 * toFloat (mainWidth model) |> round


headerHeight =
    45


footerHeight =
    45


hPadding =
    18
