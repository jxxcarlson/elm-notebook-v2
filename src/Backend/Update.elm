module Backend.Update exposing
    ( createNotebook
    , getClonedNotebook
    , pullNotebook
    , safeUpdateSlugDictWithBook
    , updateSlugDictWithBook
    )

import BackendHelper
import Dict
import Lamdera
import Notebook.Book as Book exposing (Book)
import NotebookDict
import Types exposing (BackendModel, BackendMsg(..))


type alias Model =
    BackendModel


getClonedNotebook : Model -> String -> String -> String -> String -> ( Model, Cmd BackendMsg )
getClonedNotebook model currentUsername author id clientId =
    let
        _ =
            Debug.log "@@getClonedNotebook" ( author, id )
    in
    case NotebookDict.lookup author id model.userToNoteBookDict of
        Ok book ->
            if book.public == False then
                ( model, Lamdera.sendToFrontend clientId (Types.SendMessage <| "Sorry, that notebook is private") )

            else
                let
                    newModel =
                        BackendHelper.getUUID model
                in
                ( newModel
                , Lamdera.sendToFrontend clientId
                    (Types.GotNotebook
                        { book
                            | author = currentUsername
                            , id = newModel.uuid
                            , slug = BackendHelper.compress (currentUsername ++ "-" ++ book.title)
                            , origin = Just book.slug
                            , public = False
                            , dirty = True
                        }
                    )
                )

        Err _ ->
            ( model, Lamdera.sendToFrontend clientId (Types.SendMessage <| "Sorry, couldn't get that notebook (1)") )


pullNotebook : Model -> String -> String -> String -> String -> ( Model, Cmd BackendMsg )
pullNotebook model clientId username origin id =
    case Dict.get origin model.slugDict of
        Just notebookRecord ->
            case NotebookDict.lookup notebookRecord.author notebookRecord.id model.userToNoteBookDict of
                Ok book ->
                    ( model
                    , Lamdera.sendToFrontend clientId
                        (Types.GotNotebook
                            { book
                                | author = username
                                , slug = BackendHelper.compress (username ++ "-" ++ book.title)
                                , origin = Just origin
                                , id = id
                            }
                        )
                    )

                Err _ ->
                    ( model, Lamdera.sendToFrontend clientId (Types.SendMessage <| "Sorry, couldn't get that notebook (1)") )

        Nothing ->
            ( model, Lamdera.sendToFrontend clientId (Types.SendMessage <| "Sorry, couldn't get the notebook record (2)") )


updateSlugDictWithBook : Book -> Model -> Model
updateSlugDictWithBook book model =
    let
        oldSlugDict =
            model.slugDict

        newSlugDict =
            Dict.insert book.slug { id = book.id, author = book.author, public = book.public } oldSlugDict
    in
    { model | slugDict = newSlugDict }


safeUpdateSlugDictWithBook : Book -> Model -> Model
safeUpdateSlugDictWithBook book model =
    case Dict.get book.slug model.slugDict of
        Just _ ->
            model

        Nothing ->
            updateSlugDictWithBook book model


createNotebook : Model -> String -> String -> String -> ( Model, Cmd BackendMsg )
createNotebook model clientId author title =
    let
        newModel =
            BackendHelper.getUUID model

        newBook_ =
            Book.new author title

        newBook =
            { newBook_
                | id = newModel.uuid
                , author = author
                , slug = BackendHelper.compress (author ++ "-" ++ title)
                , createdAt = model.currentTime
                , updatedAt = model.currentTime
            }

        newNotebookDict =
            NotebookDict.insert newBook.author newBook.id newBook model.userToNoteBookDict
    in
    ( { newModel | userToNoteBookDict = newNotebookDict }
        |> updateSlugDictWithBook newBook
    , Lamdera.sendToFrontend clientId (Types.GotNotebook newBook)
    )
