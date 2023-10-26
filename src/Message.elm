module Message exposing (postMessage, removeMessageAfterDelay, view)

import Element as E exposing (Element)
import Element.Font as Font
import List.Extra
import Notebook.Config
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
    Process.sleep (Notebook.Config.delay * 1000) |> Task.perform (always (Types.ExecuteDelayedMessageRemoval id))


view : Int -> Int -> Types.FrontendModel -> Element Types.FrontendMsg
view width height model =
    let
        actualMessages =
            model.messages |> List.filter (\m -> List.member m.status messageTypes)

        messageTypes =
            [ Types.MSBlue, Types.MSYellow, Types.MSRed ]
    in
    if actualMessages == [] then
        E.none

    else
        E.paragraph
            [ E.width (E.px width)
            , E.height (E.px height)
            , E.paddingXY 4 12
            , View.Style.bgGray 0.0
            , View.Style.fgGray 1.0
            , E.spacing 12
            , Font.size 12
            , E.scrollbarX
            ]
            (actualMessages |> List.Extra.uniqueBy (\m -> m.txt) |> List.map handleMessageInFooter |> List.intersperse (E.el [ Font.size 12, Font.color (E.rgb 0.4 0.4 1.0) ] (E.text ", ")))



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
