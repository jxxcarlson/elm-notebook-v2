module View.Geometry exposing
    ( appHeight
    , appWidth
    , bodyHeight
    , footerHeight
    , hPadding
    , headerHeight
    , loweRightSidePanelHeight
    , mainColumnHeight
    , notebookWidth
    , sidePanelWidth
    )


appWidth : { a | windowWidth : Int } -> Int
appWidth model =
    min 1300 model.windowWidth


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
    appWidth model - sidePanelWidth model


sidePanelWidth : { a | windowWidth : Int } -> Int
sidePanelWidth model =
    0.4 * toFloat (appWidth model) |> round


headerHeight =
    45


footerHeight =
    45


hPadding =
    18
