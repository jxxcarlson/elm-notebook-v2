module Message exposing (postMessage, removeMessageAfterDelay, viewSmall)

import Element as E exposing (Element)
import Element.Font as Font
import Process
import Task
import Types
import View.Color
import View.Style


postMessage : String -> Types.MessageStatus -> Types.FrontendModel -> ( Types.FrontendModel, Cmd Types.FrontendMsg )
postMessage str status model =
    ( { model
        | messageId = model.messageId + 1
        , messages =
            model.messages ++ [ { id = model.messageId, txt = str, status = status } ]
      }
    , removeMessageAfterDelay model.messageId
    )


removeMessageAfterDelay id =
    Process.sleep (4 * 1000) |> Task.perform (always (Types.ExecuteDelayedMessageRemoval id))


viewSmall : Int -> Types.FrontendModel -> Element Types.FrontendMsg
viewSmall width model =
    let
        actualMessages =
            model.messages |> List.filter (\m -> List.member m.status messageTypes)

        messageTypes =
            if model.showEditor then
                [ Types.MSBlue

                --, Types.MSYellow
                , Types.MSRed
                ]

            else
                [ Types.MSBlue, Types.MSRed ]
    in
    if actualMessages == [] then
        E.none

    else
        E.paragraph
            [ E.width (E.px width)
            , E.height E.fill
            , E.paddingXY 4 12
            , View.Style.bgGray 0.0
            , View.Style.fgGray 1.0
            , E.spacing 12
            , Font.size 12
            ]
            (actualMessages |> List.map handleMessageInFooter)


view : Types.FrontendModel -> Element Types.FrontendMsg
view model =
    let
        messageTypes =
            if model.showEditor then
                [ Types.MSBlue

                --, Types.MSYellow
                , Types.MSRed
                ]

            else
                [ Types.MSBlue, Types.MSRed ]
    in
    E.paragraph
        [ E.width E.fill
        , E.height (E.px 30)
        , E.paddingXY 8 8
        , View.Style.bgGray 0.1
        , View.Style.fgGray 1.0
        , E.spacing 12
        ]
        (model.messages |> List.filter (\m -> List.member m.status messageTypes) |> List.map handleMessageInFooter)



-- (model.messages |> List.map handleMessageInFooter)


style : List (E.Attr decorative msg) -> List (E.Attr decorative msg)
style attr =
    [ Font.size 14 ] ++ attr


handleMessageInFooter : Types.Message -> Element msg
handleMessageInFooter { txt, status } =
    case status of
        Types.MSWhite ->
            E.el (style []) (E.text txt)

        Types.MSYellow ->
            E.el (style [ Font.color View.Color.yellow ]) (E.text txt)

        Types.MSBlue ->
            E.el (style [ Font.color (E.rgb 0.4 0.4 1.0) ]) (E.text txt)

        Types.MSRed ->
            E.el (style [ Font.color View.Color.red ]) (E.text txt)
