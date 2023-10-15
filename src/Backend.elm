module Backend exposing (..)

import Authentication
import Backend.Authentication
import Backend.Data
import Backend.Notebook
import Backend.Update
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
    ( { randomSeed = Random.initialSeed 1234
      , uuidCount = 0
      , uuid = "aldkjf;ladjkf;dalkjf;ldkjf"
      , randomAtmosphericInt = Nothing
      , currentTime = Time.millisToPosix 0

      -- NOTEBOOK
      , usernameToPackageDictDict = Dict.empty
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

        Types.SignInBEDev ->
            Backend.Authentication.signIn model clientId "localuser" (Authentication.encryptForTransit "asdfasdf")

        Types.SignUpBE username encryptedPassword email ->
            Backend.Authentication.signUpUser model sessionId clientId username encryptedPassword email

        Types.SignOutBE mUsername ->
            Backend.Authentication.signoutBE model clientId mUsername

        Types.SignInBE username encryptedPassword ->
            Backend.Authentication.signIn model clientId username encryptedPassword

        -- DATA
        Types.DeleteDataSet dataSetMetaData ->
            let
                dataSetLibrary =
                    Dict.remove dataSetMetaData.identifier model.dataSetLibrary
            in
            ( { model | dataSetLibrary = dataSetLibrary }, Cmd.none )

        Types.SaveDataSet dataSetMetaData ->
            Backend.Data.saveDataSet model clientId dataSetMetaData

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
            Backend.Data.createDataSet model clientId dataSet_

        -- NOTEBOOKS
        Types.SaveElmJsonDependenciesBE username elmJsonDependenciesFromUser ->
            ( { model
                | usernameToPackageDictDict =
                    Dict.insert username elmJsonDependenciesFromUser (model.usernameToPackageDictDict |> Debug.log "DICT_TO_INSERT_FOR_USER")
              }
            , Cmd.none
            )

        Types.GetUsersNotebooks username ->
            let
                notebooks =
                    NotebookDict.allForUser username model.userToNoteBookDict
            in
            ( model
            , Cmd.batch
                [ sendToFrontend clientId (GotNotebooks Nothing notebooks)
                , sendToFrontend clientId (GotPackageDict (Dict.get username model.usernameToPackageDictDict |> Maybe.withDefault Dict.empty))
                ]
            )

        Types.GetPublicNotebook slug ->
            Backend.Notebook.getPublicNotebook model clientId slug

        Types.GetPublicNotebooks maybeBook username ->
            ( model, sendToFrontend clientId (GotNotebooks maybeBook (NotebookDict.allPublicWithAuthor username model.userToNoteBookDict)) )

        Types.UpdateSlugDict book ->
            ( Backend.Update.updateSlugDictWithBook book model, Cmd.none )

        Types.GetClonedNotebook username slug ->
            Backend.Update.getClonedNotebook model username slug clientId

        Types.GetPulledNotebook username origin slug id ->
            Backend.Update.pullNotebook model clientId username origin id

        Types.SaveNotebook book ->
            let
                newNotebookDict =
                    NotebookDict.insert book.author book.id book model.userToNoteBookDict
            in
            ( { model | userToNoteBookDict = newNotebookDict } |> Backend.Update.safeUpdateSlugDictWithBook book, Cmd.none )

        Types.CreateNotebook author title ->
            Backend.Update.createNotebook model clientId author title

        Types.ImportNewBook username book ->
            Backend.Notebook.importNewBook model clientId username book

        Types.DeleteNotebook book ->
            Backend.Notebook.deleteNotebook model book


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
