module Frontend.Notebook exposing
    ( clone
    , duplicate
    , importLoaded
    , pull
    , setCurrentNotebook
    , setShowNotebookState
    )

import Authentication
import BackendHelper
import Browser exposing (UrlRequest(..))
import Browser.Dom
import Browser.Events
import Browser.Navigation as Nav
import Dict
import File
import File.Download
import File.Select
import Frontend.Authentication
import Frontend.Data
import Frontend.ElmCompilerInterop
import Frontend.Message
import Frontend.UIHelper
import Frontend.Update
import Html exposing (Html)
import Keyboard
import Lamdera exposing (sendToBackend)
import List.Extra
import Message
import Navigation
import Notebook.Action
import Notebook.Book exposing (Book)
import Notebook.Cell exposing (CellState(..), CellType(..), CellValue(..))
import Notebook.Codec
import Notebook.DataSet
import Notebook.Eval
import Notebook.EvalCell
import Notebook.Package
import Notebook.Types exposing (MessageItem(..))
import Notebook.Update
import Ports
import Predicate
import Random
import Task
import Time
import Types exposing (AppMode(..), AppState(..), ClockState(..), DeleteNotebookState(..), FrontendModel, FrontendMsg(..), MessageStatus(..), PopupState(..), ShowNotebooks(..), SignupState(..), ToBackend(..), ToFrontend(..))
import Url exposing (Url)
import User
import View.Main


type alias Model =
    Types.FrontendModel


setCurrentNotebook model book =
    -- @TODO: Init book
    case model.currentUser of
        Nothing ->
            ( model, Cmd.none )

        Just user_ ->
            let
                bookSlugs =
                    Notebook.EvalCell.booksToInclude book
                        |> Debug.log "@@booksToInclude"

                getCellsToIncludeCmd =
                    Notebook.EvalCell.getCellsToInclude bookSlugs

                previousBook =
                    model.currentBook

                currentBook =
                    Notebook.Book.initializeCellState book
                        |> (\b -> { b | dirty = False })
                        |> Notebook.Book.clearValues

                newBooks =
                    model.books
                        |> List.Extra.setIf (\b -> b.id == currentBook.id) currentBook
                        |> List.Extra.setIf (\b -> b.id == previousBook.id) previousBook

                user =
                    { user_ | currentNotebookId = Just book.id }

                newModel =
                    { model
                        | evalState = Notebook.EvalCell.updateEvalStateWithCells [] currentBook.cells Notebook.Types.emptyEvalState
                        , books = newBooks
                        , includedCells = []
                        , currentBook = currentBook
                    }
            in
            ( { newModel
                | currentUser = Just user
                , showErrorPanel = True
                , errorReports = []
              }
            , Cmd.batch
                [ sendToBackend (UpdateUserWith user)
                , sendToBackend (SaveNotebook previousBook)
                , Notebook.Package.installNewPackages currentBook.packageNames
                , getCellsToIncludeCmd
                ]
            )


importLoaded model dataString =
    case Notebook.Codec.importBook dataString of
        Err _ ->
            Message.postMessage "Error decoding imported file (2)" Types.MSRed model

        Ok newBook ->
            case model.currentUser of
                Nothing ->
                    ( model, Cmd.none )

                Just user ->
                    ( model, sendToBackend (ImportNewBook user.username newBook) )


clone model =
    if not <| Predicate.canClone model then
        ( model, Cmd.none )

    else
        case model.currentUser of
            Nothing ->
                ( model, Cmd.none )

            Just user ->
                ( model, sendToBackend (GetClonedNotebook user.username model.currentBook.slug) )


pull model =
    case model.currentUser of
        Nothing ->
            ( model, Cmd.none )

        Just user ->
            let
                getOrigin : Book -> String
                getOrigin book =
                    book.origin |> Maybe.withDefault "???"

                getUsername : Maybe User.User -> String
                getUsername user_ =
                    user_ |> Maybe.map .username |> Maybe.withDefault "???"
            in
            ( model
            , sendToBackend
                (GetPulledNotebook user.username
                    (getOrigin model.currentBook)
                    model.currentBook.slug
                    model.currentBook.id
                )
            )


duplicate : Model -> ( Model, Cmd FrontendMsg )
duplicate model =
    let
        book =
            Notebook.Book.copy model.currentBook

        currentBook =
            book

        books =
            book :: model.books
    in
    ( { model | currentBook = currentBook, books = books }, Lamdera.sendToBackend (SaveNotebook book) )


setShowNotebookState model state =
    let
        cmd =
            case state of
                ShowUserNotebooks ->
                    sendToBackend (GetUsersNotebooks (model.currentUser |> Maybe.map .username |> Maybe.withDefault "--@@--"))

                ShowPublicNotebooks ->
                    sendToBackend (GetPublicNotebooks Nothing (model.currentUser |> Maybe.map .username |> Maybe.withDefault "--@@--"))
    in
    ( { model | showNotebooks = state }, cmd )
