module Frontend.Message exposing (received)

import Lamdera
import Message
import Types



--submitted : Types.FrontendModel -> ( Types.FrontendModel, Cmd Types.FrontendMsg )
--submitted model =
--    let
--        chatMessage =
--            { sender = model.currentUser |> Maybe.map .username |> Maybe.withDefault "anon"
--            , subject = ""
--            , content = model.chatMessageFieldContent
--            , date = model.currentTime
--            }
--    in
--    ( { model | chatMessageFieldContent = "", messages = model.messages }
--    , Effect.Command.batch
--        [ Effect.Lamdera.sendToBackend (Types.ChatMsgSubmitted chatMessage)
--        , View.Chat.focusMessageInput
--        , View.Chat.scrollChatToBottom
--        ]
--    )


received : Types.FrontendModel -> Types.Message -> ( Types.FrontendModel, Cmd Types.FrontendMsg )
received model message_ =
    let
        message =
            { message_ | id = model.messageId }

        newMessages =
            if List.member message.status [ Types.MSRed, Types.MSYellow, Types.MSGreen ] then
                [ message ]

            else
                model.messages
    in
    if message.txt == "Sorry, password and username don't match" then
        ( { model
            | messageId = model.messageId + 1
            , inputPassword = ""
            , messages = newMessages
          }
        , Message.removeMessageAfterDelay model.messageId
        )

    else
        ( { model
            | messageId = model.messageId + 1
            , messages = newMessages
          }
        , Message.removeMessageAfterDelay model.messageId
        )
