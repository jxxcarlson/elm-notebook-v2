module Backend exposing (..)

import Authentication
import Backend.Authentication
import BackendHelper
import Dict exposing (Dict)
import Env exposing (Mode(..))
import Hex
import Lamdera exposing (ClientId, SessionId, sendToFrontend)
import Notebook.Book
import Notebook.DataSet
import Notebook.Utility
import NotebookDict
import Random
import Time
import Token
import Types exposing (BackendModel, BackendMsg, MessageStatus(..), ToFrontend(..))


type alias Model =
    BackendModel


app =
    Lamdera.backend
        { init = init
        , update = update
        , updateFromFrontend = updateFromFrontend
        , subscriptions = \m -> Time.every 10000 Types.Tick
        }


init : ( Model, Cmd BackendMsg )
init =
    ( { message = "Hello!"

      -- RANDOM
      , randomSeed = Random.initialSeed 1234
      , uuidCount = 0
      , uuid = "aldkjf;ladjkf;dalkjf;ldkjf"
      , randomAtmosphericInt = Nothing
      , currentTime = Time.millisToPosix 0

      -- NOTEBOOK
      , dataSetLibrary = Dict.empty
      , userToNoteBookDict = Dict.empty
      , slugDict = Dict.empty

      -- USER
      , authenticationDict = Dict.empty

      -- DOCUMENTS
      }
    , Cmd.none
    )


update : BackendMsg -> Model -> ( Model, Cmd BackendMsg )
update msg model =
    case msg of
        Types.NoOpBackendMsg ->
            ( model, Cmd.none )

        Types.Tick newTime ->
            ( { model | currentTime = newTime }, Cmd.none )


updateFromFrontend : SessionId -> ClientId -> Types.ToBackend -> Model -> ( Model, Cmd BackendMsg )
updateFromFrontend sessionId clientId msg model =
    case msg of
        Types.NoOpToBackend ->
            ( model, Cmd.none )

        Types.GetRandomSeed ->
            let
                ( _, newRandomSeed ) =
                    Random.step (Random.float 0 1) model.randomSeed
            in
            ( { model | randomSeed = newRandomSeed }, sendToFrontend clientId (GotRandomSeed newRandomSeed) )

        -- ADMIN
        Types.RunTask ->
            ( model, Cmd.none )

        Types.SendUsers ->
            ( model, sendToFrontend clientId (GotUsers (Authentication.users model.authenticationDict)) )

        -- USER
        Types.UpdateUserWith user ->
            ( { model | authenticationDict = Authentication.updateUser user model.authenticationDict }, Cmd.none )

        --SignInBE username encryptedPassword ->
        --    Backend.Authentication.signIn model sessionId clientId username encryptedPassword
        Types.SignInBEDev ->
            Backend.Authentication.signIn model sessionId clientId "localuser" (Authentication.encryptForTransit "asdfasdf")

        Types.SignUpBE username encryptedPassword email ->
            Backend.Authentication.signUpUser model sessionId clientId username encryptedPassword email

        Types.SignOutBE mUsername ->
            case mUsername of
                Nothing ->
                    ( model, Cmd.none )

                Just username ->
                    case Env.mode of
                        Env.Production ->
                            Backend.Authentication.signOut model username clientId

                        Env.Development ->
                            Backend.Authentication.signOut model username clientId
                                |> (\( m1, c1 ) ->
                                        let
                                            ( m2, c2 ) =
                                                -- Backend.Update.cleanup m1 sessionId clientId
                                                ( m1, c1 )
                                        in
                                        ( m2, Cmd.batch [ c1, c2 ] )
                                   )

        Types.SignInBE username encryptedPassword ->
            case Dict.get username model.authenticationDict of
                Just userData ->
                    if Authentication.verify username encryptedPassword model.authenticationDict then
                        let
                            user =
                                userData.user

                            result =
                                NotebookDict.lookup user.username
                                    (user.currentNotebookId |> Maybe.withDefault "--xx--")
                                    model.userToNoteBookDict

                            curentBookCmd =
                                case result of
                                    Err _ ->
                                        Cmd.none

                                    Ok book ->
                                        sendToFrontend clientId (GotNotebook book)
                        in
                        ( model
                        , Cmd.batch
                            [ sendToFrontend clientId (SendUser userData.user)
                            , curentBookCmd
                            , getListOfDataSets clientId model Types.PublicDatasets
                            , getListOfDataSets clientId model (Types.UserDatasets user.username)
                            , sendToFrontend clientId (GotNotebooks Nothing (NotebookDict.allForUser username model.userToNoteBookDict))
                            ]
                        )

                    else
                        ( model, sendToFrontend clientId (SendMessage <| "Sorry, password and username don't match (1)") )

                Nothing ->
                    ( model, sendToFrontend clientId (SendMessage <| "Sorry, password and username don't match (2)") )

        -- DATA
        Types.DeleteDataSet dataSetMetaData ->
            let
                dataSetLibrary =
                    Dict.remove dataSetMetaData.identifier model.dataSetLibrary
            in
            ( { model | dataSetLibrary = dataSetLibrary }, Cmd.none )

        Types.SaveDataSet dataSetMetaData ->
            case Dict.get dataSetMetaData.identifier model.dataSetLibrary of
                Nothing ->
                    ( model, sendToFrontend clientId (SendMessage <| "Could not save data set " ++ dataSetMetaData.name) )

                Just dataSet ->
                    let
                        newDataSet =
                            { dataSet
                                | modifiedAt = model.currentTime
                                , name = dataSetMetaData.name
                                , description = dataSetMetaData.description
                                , public = dataSetMetaData.public
                            }

                        dataSetLibrary =
                            Dict.insert dataSetMetaData.identifier newDataSet model.dataSetLibrary
                    in
                    ( { model | dataSetLibrary = dataSetLibrary }
                    , sendToFrontend clientId (SendMessage <| "Data set " ++ dataSet.name ++ " saved")
                    )

        Types.GetListOfDataSets description ->
            --- getListOfDataSets clientId model description
            case description of
                Types.PublicDatasets ->
                    let
                        publicDataSets : List Notebook.DataSet.DataSetMetaData
                        publicDataSets =
                            List.filter (\dataSet -> dataSet.public) (Dict.values model.dataSetLibrary)
                                |> List.map Notebook.DataSet.extractMetaData
                    in
                    ( model, sendToFrontend clientId (GotListOfPublicDataSets publicDataSets) )

                Types.UserDatasets username ->
                    let
                        userDatasets =
                            List.filter (\dataSet -> dataSet.author == username) (Dict.values model.dataSetLibrary)
                                |> List.map Notebook.DataSet.extractMetaData
                    in
                    ( model, sendToFrontend clientId (GotListOfPrivateDataSets userDatasets) )

        Types.GetData index identifier variable ->
            case Dict.get identifier model.dataSetLibrary of
                Nothing ->
                    ( model, sendToFrontend clientId (SendMessage <| "Sorry, no data for " ++ identifier) )

                Just dataSet ->
                    ( model, sendToFrontend clientId (GotData index variable dataSet) )

        Types.GetDataSetForDownload identifier ->
            case Dict.get identifier model.dataSetLibrary of
                Nothing ->
                    ( model, sendToFrontend clientId (SendMessage <| "Sorry, no data for " ++ identifier) )

                Just dataSet ->
                    ( model, sendToFrontend clientId (GotDataForDownload dataSet) )

        Types.CreateDataSet dataSet_ ->
            let
                identifier =
                    getUniqueIdentifier dataSet_.identifier model.dataSetLibrary

                dataSet =
                    { dataSet_
                        | createdAt = model.currentTime
                        , modifiedAt = model.currentTime
                        , identifier = identifier
                    }

                dataSetLibrary =
                    Dict.insert identifier dataSet model.dataSetLibrary
            in
            ( { model | dataSetLibrary = dataSetLibrary }
            , sendToFrontend clientId (SendMessage <| "Data set " ++ dataSet.name ++ " added with identifier = " ++ identifier)
            )

        -- NOTEBOOKS
        Types.GetUsersNotebooks username ->
            ( model, sendToFrontend clientId (GotNotebooks Nothing (NotebookDict.allForUser username model.userToNoteBookDict)) )

        Types.GetPublicNotebook slug ->
            let
                notebooks =
                    NotebookDict.allPublic model.userToNoteBookDict |> List.filter (\b -> String.contains slug b.slug)
            in
            case List.head notebooks of
                Nothing ->
                    ( model, sendToFrontend clientId (SendMessage <| "Sorry, that notebook does not exist") )

                Just notebook ->
                    ( model, Cmd.batch [ sendToFrontend clientId (GotPublicNotebook notebook), sendToFrontend clientId (SendMessage <| "Found that notebook!") ] )

        Types.GetPublicNotebooks maybeBook username ->
            ( model, sendToFrontend clientId (GotNotebooks maybeBook (NotebookDict.allPublicWithAuthor username model.userToNoteBookDict)) )

        Types.UpdateSlugDict book ->
            case String.split "." book.slug of
                author :: slug :: [] ->
                    let
                        oldSlugDict =
                            model.slugDict

                        newSlugDict =
                            Dict.insert book.slug { id = book.id, author = book.author, public = book.public } oldSlugDict
                    in
                    ( { model | slugDict = newSlugDict }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        Types.GetClonedNotebook username slug ->
            case Dict.get slug model.slugDict of
                Just notebookRecord ->
                    case NotebookDict.lookup notebookRecord.author notebookRecord.id model.userToNoteBookDict of
                        Ok book ->
                            if book.public == False then
                                ( model, sendToFrontend clientId (SendMessage <| "Sorry, that notebook is private") )

                            else
                                let
                                    newModel =
                                        BackendHelper.getUUID model
                                in
                                ( newModel
                                , sendToFrontend clientId
                                    (GotNotebook
                                        { book
                                            | author = username
                                            , id = newModel.uuid
                                            , slug = BackendHelper.compress (username ++ "-" ++ book.title)
                                            , origin = Just slug
                                            , public = False
                                            , dirty = True
                                        }
                                    )
                                )

                        Err _ ->
                            ( model, sendToFrontend clientId (SendMessage <| "Sorry, couldn't get that notebook (1)") )

                Nothing ->
                    ( model, sendToFrontend clientId (SendMessage <| "Sorry, couldn't get that notebook (2)") )

        Types.GetPulledNotebook username origin slug id ->
            case Dict.get origin model.slugDict of
                Just notebookRecord ->
                    case NotebookDict.lookup notebookRecord.author notebookRecord.id model.userToNoteBookDict of
                        Ok book ->
                            ( model
                            , sendToFrontend clientId
                                (GotNotebook
                                    { book
                                        | author = username
                                        , slug = BackendHelper.compress (username ++ "-" ++ book.title)
                                        , origin = Just origin
                                        , id = id
                                    }
                                )
                            )

                        Err _ ->
                            ( model, sendToFrontend clientId (SendMessage <| "Sorry, couldn't get that notebook (1)") )

                Nothing ->
                    ( model, sendToFrontend clientId (SendMessage <| "Sorry, couldn't get the notebook record (2)") )

        Types.SaveNotebook book ->
            let
                newNotebookDict =
                    NotebookDict.insert book.author book.id book model.userToNoteBookDict
            in
            ( { model | userToNoteBookDict = newNotebookDict }, Cmd.none )

        Types.CreateNotebook author title ->
            let
                newModel =
                    BackendHelper.getUUID model

                newBook_ =
                    Notebook.Book.new author title

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
            ( { newModel | userToNoteBookDict = newNotebookDict }, sendToFrontend clientId (GotNotebook newBook) )

        Types.ImportNewBook username book ->
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
            ( { newModel | userToNoteBookDict = newNotebookDict }, sendToFrontend clientId (GotNotebook newBook) )

        Types.DeleteNotebook book ->
            let
                newNotebookDict =
                    NotebookDict.remove book.author book.id model.userToNoteBookDict
            in
            ( { model | userToNoteBookDict = newNotebookDict }, Cmd.none )


setupUser : Model -> ClientId -> String -> String -> String -> ( BackendModel, Cmd BackendMsg )
setupUser model clientId email transitPassword username =
    let
        ( randInt, seed ) =
            Random.step (Random.int (Random.minInt // 2) (Random.maxInt - 1000)) model.randomSeed

        randomHex =
            Hex.toString randInt |> String.toUpper

        tokenData =
            Token.get seed

        user =
            { username = username
            , id = tokenData.token
            , realname = "Undefined"
            , email = email
            , created = model.currentTime
            , modified = model.currentTime
            , locked = False
            , currentNotebookId = Nothing
            }
    in
    case Authentication.insert user randomHex transitPassword model.authenticationDict of
        Err str ->
            ( { model | randomSeed = seed }, sendToFrontend clientId (SendMessage ("Error: " ++ str)) )

        Ok authDict ->
            ( { model | randomSeed = seed, authenticationDict = authDict }
            , Cmd.batch
                [ sendToFrontend clientId (SendMessage "Success! You have set up your account")
                , sendToFrontend clientId (SendUser user)
                ]
            )


idMessage model =
    "ids: " ++ (List.map .id model.documents |> String.join ", ")


getUniqueIdentifier : String -> Dict String a -> String
getUniqueIdentifier id dict =
    case Dict.get id dict of
        Nothing ->
            id

        Just _ ->
            getUniqueIdentifier_ 1 id dict


getUniqueIdentifier_ : Int -> String -> Dict String a -> String
getUniqueIdentifier_ counter id dict =
    case Dict.get (id ++ "-" ++ String.fromInt counter) dict of
        Nothing ->
            id ++ "-" ++ String.fromInt counter

        Just _ ->
            getUniqueIdentifier_ (counter + 1) id dict


getListOfDataSets : ClientId -> BackendModel -> Types.DataSetDescription -> Cmd backendMsg
getListOfDataSets clientId model description =
    case description of
        Types.PublicDatasets ->
            let
                publicDataSets : List Notebook.DataSet.DataSetMetaData
                publicDataSets =
                    List.filter (\dataSet -> dataSet.public) (Dict.values model.dataSetLibrary)
                        |> List.map Notebook.DataSet.extractMetaData
            in
            sendToFrontend clientId (GotListOfPublicDataSets publicDataSets)

        Types.UserDatasets username ->
            let
                userDatasets =
                    List.filter (\dataSet -> dataSet.author == username) (Dict.values model.dataSetLibrary)
                        |> List.map Notebook.DataSet.extractMetaData
            in
            sendToFrontend clientId (GotListOfPrivateDataSets userDatasets)



--case description of
--    PublicDatasets ->
--        let
--            publicDataSets : List Notebook.DataSet.DataSetMetaData
--            publicDataSets =
--                --List.filter (\dataSet -> dataSet.public) (Dict.values model.dataSetLibrary)
--                Dict.values model.dataSetLibrary
--                    |> List.map Notebook.DataSet.extractMetaData
--        in
--        sendToFrontend clientId (GotListOfPublicDataSets publicDataSets)
--
--    UserDatasets username ->
--        let
--            userDatasets =
--                List.filter (\dataSet -> dataSet.author == username) (Dict.values model.dataSetLibrary)
--                    |> List.map Notebook.DataSet.extractMetaData
--        in
--        sendToFrontend clientId (GotListOfPublicDataSets userDatasets)
