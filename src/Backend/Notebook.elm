module Backend.Notebook exposing
    ( deleteNotebook
    , getPublicNotebook
    , importNewBook
    )

import BackendHelper
import Lamdera
import Notebook.Book exposing (Book)
import NotebookDict
import Types exposing (BackendModel, BackendMsg)


deleteNotebook : BackendModel -> Book -> ( BackendModel, Cmd BackendMsg )
deleteNotebook model book =
    let
        newNotebookDict =
            NotebookDict.remove book.author book.id model.userToNoteBookDict
    in
    ( { model | userToNoteBookDict = newNotebookDict }, Cmd.none )


getPublicNotebook model clientId slug =
    let
        notebooks =
            NotebookDict.allPublic model.userToNoteBookDict |> List.filter (\b -> String.contains slug b.slug)
    in
    case List.head notebooks of
        Nothing ->
            ( model, Lamdera.sendToFrontend clientId (Types.SendMessage <| "Sorry, that notebook does not exist") )

        Just notebook ->
            ( model, Cmd.batch [ Lamdera.sendToFrontend clientId (Types.GotPublicNotebook notebook), Lamdera.sendToFrontend clientId (Types.SendMessage <| "Found that notebook!") ] )


importNewBook : BackendModel -> String -> String -> Book -> ( BackendModel, Cmd BackendMsg )
importNewBook model clientId username book =
    let
        newModel =
            BackendHelper.getUUID model

        newBook =
            { book
                | id = newModel.uuid
                , author = username
                , slug = BackendHelper.compress (username ++ "-" ++ book.title)
                , createdAt = model.currentTime
                , updatedAt = model.currentTime
            }

        newNotebookDict =
            NotebookDict.insert newBook.author newBook.id newBook model.userToNoteBookDict
    in
    ( { newModel | userToNoteBookDict = newNotebookDict }, Lamdera.sendToFrontend clientId (Types.GotNotebook newBook) )
