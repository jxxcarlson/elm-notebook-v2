module Backend.Session exposing (reconnect, removeStaleSessions, sendUserData)

import Authentication
import BiDict
import Dict
import Lamdera exposing (ClientId)
import Session
import Types exposing (BackendModel, BackendMsg, MessageStatus(..), ToFrontend(..))
import User exposing (User)


sendUserData : BackendModel -> String -> { a | user : User } -> Lamdera.SessionId -> ClientId -> List (Cmd ToFrontend)
sendUserData model username userData sessionId clientId =
    let
        foo =
            1
    in
    [ if username == "guest" then
        Cmd.none

      else
        Lamdera.sendToFrontend clientId (UserSignedIn userData.user clientId)
    ]


removeStaleSessions : Types.BackendModel -> Types.BackendModel
removeStaleSessions model =
    let
        ( newSessions, newSessionInfo ) =
            Session.removeStaleSessions model.currentTime ( model.sessions, model.sessionInfo )
    in
    { model
        | sessions = newSessions
        , sessionInfo = newSessionInfo
    }


reconnect : Types.BackendModel -> Lamdera.SessionId -> Lamdera.ClientId -> Cmd Types.ToFrontend
reconnect model sessionId clientId =
    let
        maybeUsername =
            BiDict.get sessionId model.sessions

        maybeUser : Maybe User.User
        maybeUser =
            Maybe.andThen (\username -> Dict.get username model.authenticationDict |> Maybe.map .user) maybeUsername
    in
    case maybeUser of
        Nothing ->
            Lamdera.sendToFrontend clientId (Types.MessageReceived { id = 1, txt = "Sorry, could not sign you back in", status = Types.MSRed })

        Just user ->
            Lamdera.sendToFrontend clientId (Types.UserSignedIn user clientId)
