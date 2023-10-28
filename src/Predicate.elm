module Predicate exposing (canClone, canSave, noUserSignedIn, regularUser)

import Types


regularUser : Types.FrontendModel -> Bool
regularUser model =
    case model.currentUser of
        Just user ->
            user.username /= "guest"

        Nothing ->
            False


userSignedIn : Types.FrontendModel -> Bool
userSignedIn model =
    case model.currentUser of
        Just _ ->
            True

        Nothing ->
            False


noUserSignedIn : Types.FrontendModel -> Bool
noUserSignedIn model =
    case model.currentUser of
        Just _ ->
            False

        Nothing ->
            True


canSave : Types.FrontendModel -> Bool
canSave model =
    (model.currentUser |> Maybe.map .username) == Just model.currentBook.author


canClone : Types.FrontendModel -> Bool
canClone model =
    case model.currentUser of
        Just user ->
            model.currentBook.author
                /= user.username
                && (not <| String.contains user.username (Maybe.withDefault "---" model.currentBook.origin))
                && (not <| user.username == "guest")

        Nothing ->
            False
