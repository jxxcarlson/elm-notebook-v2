module Frontend exposing (app)

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
import Frontend.ElmCompilerInterop as ElmCompilerInterop
import Frontend.Message
import Frontend.Notebook
import Frontend.UIHelper
import Frontend.Update
import Html exposing (Html)
import Json.Encode
import Keyboard
import Lamdera exposing (sendToBackend)
import List.Extra
import Message
import Navigation
import Notebook.Action
import Notebook.Book exposing (Book)
import Notebook.CLI
import Notebook.Cell exposing (Cell, CellState(..), CellType(..), CellValue(..))
import Notebook.Codec
import Notebook.Compile
import Notebook.DataSet
import Notebook.ErrorReporter
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


app =
    Lamdera.frontend
        { init = init
        , onUrlRequest = UrlClicked
        , onUrlChange = UrlChanged
        , update = update
        , updateFromBackend = updateFromBackend
        , subscriptions = subscriptions
        , view = view
        }


subscriptions model =
    Sub.batch
        [ Browser.Events.onResize GotNewWindowDimensions
        , Time.every 1000 FETick
        , Sub.map KeyboardMsg Keyboard.subscriptions
        , Ports.receiveFromJS ReceivedFromJS
        , Ports.receiveJSData ReceiveJSData
        ]


init : Url.Url -> Nav.Key -> ( Model, Cmd FrontendMsg )
init url key =
    ( { key = key
      , url = url
      , messageId = 0

      -- NOTEBOOK (NEW)
      , includedCells = []
      , errorReports = []
      , showErrorPanel = True
      , theme = Notebook.Book.LightTheme
      , packagesFromCompiler = []
      , packageDict = Dict.empty
      , elmJsonError = Nothing
      , evalState = Notebook.Eval.initEmptyEvalState
      , messages = []
      , appState = Loading
      , appMode = AMWorking
      , currentTime = Time.millisToPosix 0
      , tickCount = 0
      , clockState = ClockStopped
      , pressedKeys = []
      , randomSeed = Random.initialSeed 1234
      , randomProbabilities = []
      , probabilityVectorLength = 4

      -- ADMIN
      , users = []

      --
      , inputName = ""
      , inputSearch = ""
      , inputAuthor = ""
      , inputIdentifier = ""
      , inputDescription = ""
      , inputComments = ""
      , inputData = ""
      , inputCommand = ""
      , inputPackages = ""
      , inputInitialStateValue = ""

      -- DATASETS
      , publicDataSetMetaDataList = []
      , privateDataSetMetaDataList = []

      -- NOTEBOOKS
      , kvDict = Dict.empty
      , books = []
      , currentCell = Nothing
      , cellInsertionDirection = Notebook.Types.Down
      , currentBook = Notebook.Book.scratchPad "anonymous"
      , cellContent = ""
      , currentCellIndex = 0
      , cloneReference = ""
      , deleteNotebookState = WaitingToDeleteNotebook
      , showNotebooks = ShowUserNotebooks

      -- UI
      , windowWidth = 600
      , windowHeight = 900
      , popupState = NoPopup
      , showEditor = False

      -- USER
      , signupState = HideSignUpForm
      , currentUser = Nothing
      , inputUsername = ""
      , inputSignupUsername = ""
      , inputRealname = ""
      , inputPassword = ""
      , inputPasswordAgain = ""
      , inputEmail = ""
      , inputTitle = ""
      }
    , Cmd.batch
        [ Ports.sendData "Hello there!"
        , setupWindow
        , sendToBackend GetRandomSeed
        , Navigation.urlAction url.path
        , Notebook.Package.requestPackagesFromCompiler
        ]
    )


update : FrontendMsg -> Model -> ( Model, Cmd FrontendMsg )
update msg model =
    case msg of
        NoOpFrontendMsg ->
            ( model, Cmd.none )

        CopyTextToClipboard text ->
            let
                _ =
                    Debug.log "@@@URL in CopyTextToClipboard" text
            in
            ( model, Ports.supermario_copy_to_clipboard_to_js (Json.Encode.string text) )

        GetRandomProbabilities k ->
            getRandomProbabilities model k

        GotRandomProbabilities listOfProbabilities ->
            ( { model | randomProbabilities = listOfProbabilities }
            , Cmd.none
            )

        ToggleTheme theme ->
            case theme of
                Notebook.Book.DarkTheme ->
                    ( { model | theme = Notebook.Book.LightTheme }, Cmd.none )

                Notebook.Book.LightTheme ->
                    ( { model | theme = Notebook.Book.DarkTheme }, Cmd.none )

        -- ELM COMPILER/JS INTEROP
        SendProgramToBeCompiled ->
            ( model
            , Notebook.Compile.testCompilation
            )

        GotCompiledProgram result ->
            case result of
                Err e ->
                    Message.postMessage "Error compiling program" Types.MSRed model

                Ok program ->
                    Message.postMessage "Received compiled program" Types.MSRed model
                        |> (\( model_, cmd ) -> ( model_, Cmd.batch [ cmd, File.Download.string "main.js" "text/javascript" program ] ))

        ExecuteDelayedFunction ->
            ( model, Notebook.Package.nowSendPackageList model )

        ExecuteDelayedFunction2 ->
            ( model, Notebook.Package.requestPackagesFromCompiler )

        ExecuteDelayedMessageRemoval id ->
            ( { model | messages = List.filter (\m -> m.id /= id) model.messages }, Cmd.none )

        ExecuteCell k ->
            -- Notebook.EvalCell.executeCell k model
            ( model, Notebook.EvalCell.executeCellCommand k model )

        ExecuteCells result ->
            case result of
                Err httpError ->
                    Message.postMessage "Error executing cells" Types.MSRed model

                Ok compilerOutput ->
                    let
                        errorFreeOutput =
                            List.filter (\( _, str ) -> not (Notebook.Eval.hasReplError str)) compilerOutput

                        errorData : List ( Int, List MessageItem )
                        errorData =
                            List.filter (\( _, str ) -> Notebook.Eval.hasReplError str) compilerOutput
                                |> List.map (\( idx, str ) -> ( idx, Notebook.Eval.reportError str ))

                        updateCellsWithReport : ( Int, List MessageItem ) -> List Cell -> List Cell
                        updateCellsWithReport ( k, messages ) cells =
                            case List.Extra.getAt k cells of
                                Nothing ->
                                    cells

                                Just cell ->
                                    List.Extra.setAt k { cell | report = ( cell.index, Just messages ) } cells

                        updateCellsWithReports : List ( Int, List MessageItem ) -> List Cell -> List Cell
                        updateCellsWithReports errorData_ cells =
                            List.foldl updateCellsWithReport cells errorData_

                        oldBook =
                            model.currentBook

                        newCells =
                            updateCellsWithReports errorData model.currentBook.cells

                        newBook =
                            { oldBook | cells = newCells }

                        errorReports =
                            Notebook.ErrorReporter.collateErrorReports newCells

                        commands : List (Cmd msg)
                        commands =
                            List.map (\( idx, str ) -> Ports.encodeIndexAndSourcePair ( idx, str ) |> Ports.sendJSData) errorFreeOutput
                    in
                    ( { model | currentBook = newBook, errorReports = errorReports }, Cmd.batch commands )

        UpdateErrorReports ->
            ( { model | errorReports = Notebook.ErrorReporter.collateErrorReports model.currentBook.cells }, Cmd.none )

        ReceivedFromJS str ->
            ElmCompilerInterop.receiveReplDataFromJS model str

        ReceiveJSData rawString ->
            case String.split ":::" rawString of
                [ indexAsString, executedCode ] ->
                    case String.toInt indexAsString of
                        Nothing ->
                            ( model, Cmd.none )

                        Just index ->
                            ElmCompilerInterop.receiveDataFromJS model ( index, executedCode )

                _ ->
                    ( model, Cmd.none )

        FetchDependencies packageName ->
            ( model, Notebook.Package.fetchElmJson packageName )

        GotElmJsonDict result ->
            Notebook.Package.gotElmJsonDict model result

        GotReplyFromCompiler cell result ->
            ElmCompilerInterop.handleReplyFromElmCompiler model cell result

        KeyboardMsg keyMsg ->
            Frontend.UIHelper.handleKeyPresses model keyMsg

        FETick time ->
            Frontend.Update.periodicAction model time

        -- NAV
        UrlClicked urlRequest ->
            case urlRequest of
                Internal url ->
                    ( model, Cmd.none )

                External url ->
                    ( model
                    , Nav.load url
                    )

        UrlChanged url ->
            ( { model | url = url }
            , Cmd.none
            )

        -- SYSTEM
        GotViewport vp ->
            Frontend.UIHelper.handleViewport model vp

        GotNewWindowDimensions w h ->
            ( { model | windowWidth = w, windowHeight = h }, Cmd.none )

        ChangePopup popupState ->
            Frontend.UIHelper.handlePopups model popupState

        -- SIGN UP, IN, OUT
        SetSignupState state ->
            Frontend.Authentication.setSignupState model state

        SignUp ->
            Frontend.Authentication.signUp model

        SignIn ->
            if String.length model.inputPassword >= 8 then
                ( model
                , sendToBackend (SignInBE model.inputUsername (Authentication.encryptForTransit model.inputPassword))
                )

            else
                Message.postMessage "Password must be at least 8 letters long." Types.MSRed model

        InputUsername str ->
            ( { model | inputUsername = str }, Cmd.none )

        InputIdentifier str ->
            ( { model | inputIdentifier = str }, Cmd.none )

        InputSignupUsername str ->
            ( { model | inputSignupUsername = str }, Cmd.none )

        InputEmail str ->
            ( { model | inputEmail = str }, Cmd.none )

        InputPassword str ->
            ( { model | inputPassword = str }, Cmd.none )

        InputPasswordAgain str ->
            ( { model | inputPasswordAgain = str }, Cmd.none )

        InputTitle str ->
            ( { model | inputTitle = str }, Cmd.none )

        InputCloneReference str ->
            ( { model | cloneReference = str }, Cmd.none )

        SignOut ->
            Frontend.Update.signOut model

        -- INPUT FIELDS
        InputName str ->
            ( { model | inputName = str }, Cmd.none )

        InputSearch str ->
            ( { model | inputSearch = str }, Cmd.none )

        InputAuthor str ->
            ( { model | inputAuthor = str }, Cmd.none )

        InputDescription str ->
            ( { model | inputDescription = str }, Cmd.none )

        InputComments str ->
            ( { model | inputComments = str }, Cmd.none )

        InputData str ->
            ( { model | inputData = str }, Cmd.none )

        InputCommand str ->
            ( { model | inputCommand = str }, Cmd.none )

        InputPackages str ->
            ( { model | inputPackages = str }, Cmd.none )

        InputInitialStateValue str ->
            ( { model | inputInitialStateValue = str }, Cmd.none )

        -- DATA
        AskToDeleteDataSet dataSetMetaData ->
            Frontend.Data.askToDeleteDataSet model dataSetMetaData

        AskToSaveDataSet dataSetMetaData ->
            Frontend.Data.askToSaveDataSet model dataSetMetaData

        AskToListDataSets description ->
            ( model, Lamdera.sendToBackend (GetListOfDataSets description) )

        AskToCreateDataSet ->
            Frontend.Data.askToCreateDataSet model

        -- CELLS, NOTEBOOKS
        GetPackagesFromCompiler ->
            ( model, Notebook.Package.requestPackagesFromCompiler )

        GotPackagesFromCompiler result ->
            case result of
                Err _ ->
                    Message.postMessage "E.4" Types.MSRed model

                Ok packageList ->
                    Message.postMessage ("Loaded: " ++ (packageList |> List.filter (\p -> p.name /= "elm/core") |> List.map (.name >> shorten) |> String.join ", ")) MSYellow model
                        |> (\( modl, cmd ) -> ( { modl | packagesFromCompiler = List.filter (\p -> p.name /= "elm/core") packageList }, cmd ))

        SubmitPackageList ->
            Notebook.Package.submitPackageListFromUserInput model

        SubmitTest ->
            ( model, Cmd.none )

        PackageListSent result ->
            --case result of
            --    Err _ ->
            --        Message.postMessage "E.3" Types.MSYellow model
            --
            --    Ok str ->
            --        Message.postMessage ("Sent: " ++ str) Types.MSBlue model
            ( model, Cmd.none )

        ClearNotebookValues ->
            Notebook.Update.clearNotebookValues model.currentBook model

        ExecuteNotebook ->
            Notebook.EvalCell.executeNotebook model

        UpdateDeclarationsDictionary ->
            ( { model | evalState = Notebook.EvalCell.updateEvalStateWithCells model.includedCells model.currentBook.cells Notebook.Types.emptyEvalState }, Cmd.none )

        ToggleCellLock cell ->
            ( Notebook.Update.toggleCellLock cell model, Cmd.none )

        ChangeCellInsertionDirection direction ->
            ( { model | cellInsertionDirection = direction }, Cmd.none )

        StringDataRequested index variable ->
            ( model
            , File.Select.file [ "text/csv" ] (StringDataSelected index variable)
            )

        StringDataSelected index variable file ->
            ( model
            , Task.perform (StringDataLoaded (File.name file) index variable) (File.toString file)
            )

        StringDataLoaded fileName index variable dataString ->
            ( Notebook.Action.readData index fileName variable dataString model, Cmd.none )

        SetShowNotebooksState state ->
            Frontend.Notebook.setShowNotebookState model state

        CloneNotebook ->
            Frontend.Notebook.clone model

        PullNotebook ->
            Frontend.Notebook.pull model

        DuplicateNotebook ->
            Frontend.Notebook.duplicate model

        ExportNotebook ->
            ( model, File.Download.string (BackendHelper.compress model.currentBook.title ++ ".json") "text/json" (Notebook.Codec.exportBook model.currentBook) )

        ImportRequested ->
            ( model, File.Select.file [ "text/json" ] ImportSelected )

        ImportSelected file ->
            ( model, Task.perform ImportLoaded (File.toString file) )

        ImportLoaded dataString ->
            Frontend.Notebook.importLoaded model dataString

        SetCurrentNotebook book ->
            -- @NOTE: Init Book
            Frontend.Notebook.setCurrentNotebook model book

        TogglePublic ->
            if not (Predicate.canSave model) then
                ( model, Cmd.none )

            else
                let
                    oldBook =
                        model.currentBook

                    newBook =
                        { oldBook | public = not oldBook.public, dirty = False }
                in
                ( { model | currentBook = newBook, books = List.Extra.setIf (\b -> b.id == newBook.id) newBook model.books }
                , Cmd.batch [ sendToBackend (UpdateSlugDict newBook), sendToBackend (SaveNotebook newBook) ]
                )

        CancelDeleteNotebook ->
            ( { model | deleteNotebookState = WaitingToDeleteNotebook }, Cmd.none )

        ProposeDeletingNotebook ->
            case model.deleteNotebookState of
                WaitingToDeleteNotebook ->
                    ( { model | deleteNotebookState = CanDeleteNotebook }, Cmd.none )

                CanDeleteNotebook ->
                    let
                        newNotebookList =
                            List.filter (\b -> b.id /= model.currentBook.id) model.books
                    in
                    case List.head newNotebookList of
                        Nothing ->
                            Message.postMessage "You can't delete your last notebook." Types.MSRed model

                        Just book ->
                            ( { model
                                | deleteNotebookState = WaitingToDeleteNotebook
                                , currentBook = book
                                , books = newNotebookList
                              }
                            , sendToBackend (DeleteNotebook model.currentBook)
                            )

        NewNotebook ->
            case model.currentUser of
                Nothing ->
                    ( model, Cmd.none )

                Just user ->
                    ( model, sendToBackend (CreateNotebook user.username "New Notebook") )

        ChangeAppMode mode ->
            case mode of
                AMEditTitle ->
                    ( { model | appMode = mode, inputTitle = model.currentBook.title }, Cmd.none )

                _ ->
                    ( { model | appMode = mode }, Cmd.none )

        Reset ->
            let
                newModel =
                    { model
                        | clockState = ClockStopped
                        , tickCount = 0
                    }
            in
            ( newModel, Cmd.none )

        SetClock state ->
            ( { model | clockState = state }, Cmd.none )

        UpdateNotebookTitle ->
            if not (Predicate.canSave model) then
                Message.postMessage "You can't edit this notebook." Types.MSRed model

            else
                let
                    oldBook =
                        model.currentBook

                    compress str =
                        str |> String.toLower |> String.replace " " "-"

                    newBook =
                        { oldBook
                            | dirty = False
                            , title = model.inputTitle
                            , slug = compress (oldBook.author ++ "-" ++ model.inputTitle)
                        }
                in
                ( { model
                    | appMode = AMWorking
                    , currentBook = newBook
                    , books = List.Extra.setIf (\b -> b.id == newBook.id) newBook model.books
                  }
                , Cmd.batch
                    [ sendToBackend (SaveNotebook newBook)
                    , sendToBackend (UpdateSlugDict newBook)
                    ]
                )

        InputElmCode index str ->
            ( Notebook.Update.updateCellText model index str, Cmd.none )

        NewCodeCell cellState index ->
            Notebook.Update.makeNewCell model cellState CTCode index

        NewMarkdownCell cellState index ->
            Notebook.Update.makeNewCell model cellState CTMarkdown index

        ToggleShowErrorPanel ->
            ( { model | showErrorPanel = not model.showErrorPanel }, Cmd.none )

        DeleteCell index ->
            if List.length model.currentBook.cells <= 1 then
                ( model, Cmd.none )

            else
                ( Notebook.Update.deleteCell index model, Cmd.none )

        MoveCell index direction ->
            Notebook.Book.moveCellUpDown model index direction

        ToggleComment commented index ->
            Notebook.Update.toggleComment model commented index

        EditCell cell ->
            Notebook.Update.editCell model cell

        ClearCell index ->
            Notebook.Update.clearCell model index

        EvalCell cellState ->
            Notebook.EvalCell.processCell cellState model.currentCellIndex { model | errorReports = [] }

        MakeCellCurrent index ->
            ( { model | currentCellIndex = index }, Cmd.none )

        RunCommand ->
            Notebook.CLI.executeCommand model

        -- NOTEBOOKS
        -- ADMIN
        AdminRunTask ->
            ( model, sendToBackend RunTask )

        GetUsers ->
            ( model, sendToBackend SendUsers )


updateFromBackend : ToFrontend -> Model -> ( Model, Cmd FrontendMsg )
updateFromBackend msg model =
    case msg of
        NoOpToFrontend ->
            ( model, Cmd.none )

        GotRandomSeed seed ->
            glueUpdate (\m -> ( { m | randomSeed = seed }, Cmd.none )) (\m -> getRandomProbabilities m 2) model

        -- ADMIN
        GotUsers users ->
            ( { model | users = users }, Cmd.none )

        -- USER
        SendMessage message ->
            Message.postMessage message Types.MSBlue model

        MessageReceived message ->
            Message.postMessage message.txt Types.MSBlue model

        UserSignedIn user _ ->
            ( { model | currentUser = Just user, popupState = Types.NoPopup }, Cmd.none )

        SendUser user ->
            if user.username == "guest" then
                ( { model
                    | currentUser = Just user
                    , showNotebooks = ShowPublicNotebooks
                    , clockState = ClockStopped
                  }
                , Cmd.none
                )

            else
                ( { model
                    | currentUser = Just user
                    , showNotebooks = ShowUserNotebooks
                    , clockState = ClockStopped
                  }
                , Cmd.none
                )

        -- DATA
        GotListOfPublicDataSets dataSetMetaDataList ->
            ( { model | publicDataSetMetaDataList = dataSetMetaDataList }, Cmd.none )

        GotListOfPrivateDataSets dataSetMetaDataList ->
            ( { model | privateDataSetMetaDataList = dataSetMetaDataList }, Cmd.none )

        GotData index variable dataSet ->
            ( Notebook.Action.importData index variable dataSet model
            , Cmd.none
            )

        GotDataForDownload dataSet ->
            ( model, File.Download.string (String.replace "." "-" dataSet.identifier ++ ".csv") "text/csv" dataSet.data )

        -- NOTEBOOKS
        GotCellsToInclude cells ->
            ( { model | includedCells = cells }, Cmd.none )

        GotPackageDict packageDict ->
            ( { model | packageDict = packageDict }, Cmd.none )

        GotNotebook book_ ->
            -- @NOTE: Init Book
            let
                bookSlugs =
                    Notebook.EvalCell.booksToInclude book

                getCellsToIncludeCmd =
                    Notebook.EvalCell.getCellsToInclude bookSlugs

                book =
                    Notebook.Book.initializeCellState book_

                addOrReplaceBook xbook books =
                    if List.any (\b -> b.id == xbook.id) books then
                        List.Extra.setIf (\b -> b.id == xbook.id) xbook books

                    else
                        xbook :: books

                newModel =
                    { model | evalState = Notebook.EvalCell.updateEvalStateWithCells [] book.cells Notebook.Types.emptyEvalState, currentBook = book }
            in
            ( { newModel
                | currentBook = book |> Notebook.Book.clearValues
                , books = addOrReplaceBook book model.books
                , showErrorPanel = True
                , includedCells = []
              }
            , Cmd.batch [ getCellsToIncludeCmd, Notebook.Package.installNewPackages book.packageNames ]
            )

        GotPublicNotebook book_ ->
            -- @NOTE: Init Book
            let
                currentUser =
                    case model.currentUser of
                        Just user ->
                            user

                        Nothing ->
                            User.guest

                book =
                    Notebook.Book.initializeCellState book_

                newModel =
                    { model
                        | evalState = Notebook.EvalCell.updateEvalStateWithCells [] book.cells Notebook.Types.emptyEvalState
                        , currentBook = book |> Notebook.Book.clearValues
                    }

                addOrReplaceBook xbook books =
                    if List.any (\b -> b.id == xbook.id) books then
                        List.Extra.setIf (\b -> b.id == xbook.id) xbook books

                    else
                        xbook :: books
            in
            ( { newModel
                | currentUser = Just currentUser
                , showErrorPanel = True
                , showNotebooks = ShowPublicNotebooks
                , books = addOrReplaceBook book model.books
                , includedCells = []
              }
            , Cmd.batch
                [ sendToBackend (GetPublicNotebooks (Just book) currentUser.username)
                , Notebook.Package.installNewPackages book.packageNames
                ]
            )

        GotNotebooks maybeNotebook books ->
            -- @NOTE: Init Book
            case maybeNotebook of
                Nothing ->
                    case List.head books of
                        Nothing ->
                            ( model, Cmd.none )

                        Just book ->
                            let
                                bookSlugs =
                                    Notebook.EvalCell.booksToInclude book

                                getCellsToIncludeCmd =
                                    Notebook.EvalCell.getCellsToInclude bookSlugs

                                newModel =
                                    { model
                                        | evalState = Notebook.EvalCell.updateEvalStateWithCells model.includedCells book.cells Notebook.Types.emptyEvalState
                                        , currentBook = book
                                        , books = books
                                    }
                            in
                            Message.postMessage "OK.1" Types.MSBlue newModel
                                |> (\( model_, cmd ) ->
                                        ( model_
                                        , Cmd.batch
                                            [ cmd
                                            , getCellsToIncludeCmd
                                            , Notebook.Package.installNewPackages book.packageNames
                                            ]
                                        )
                                   )

                Just currentBook ->
                    let
                        bookSlugs =
                            Notebook.EvalCell.booksToInclude currentBook

                        getCellsToIncludeCmd =
                            Notebook.EvalCell.getCellsToInclude bookSlugs

                        newModel =
                            { model
                                | showErrorPanel = True
                                , evalState = Notebook.EvalCell.updateEvalStateWithCells model.includedCells currentBook.cells Notebook.Types.emptyEvalState
                                , currentBook = currentBook |> Notebook.Book.clearValues
                            }
                    in
                    ( { newModel
                        | books = books
                        , includedCells = []
                        , currentBook = currentBook
                      }
                    , Cmd.batch
                        [ getCellsToIncludeCmd
                        , Notebook.Package.installNewPackages currentBook.packageNames
                        ]
                    )


view : Model -> { title : String, body : List (Html.Html FrontendMsg) }
view model =
    { title = "Elm Notebook"
    , body =
        [ View.Main.view model ]
    }



--HELPERS


glueUpdate : (Model -> ( Model, Cmd FrontendMsg )) -> (Model -> ( Model, Cmd FrontendMsg )) -> Model -> ( Model, Cmd FrontendMsg )
glueUpdate f g model =
    let
        ( m1, cmd1 ) =
            f model

        ( m2, cmd2 ) =
            g m1
    in
    ( m2, Cmd.batch [ cmd1, cmd2 ] )


getRandomProbabilities : Model -> Int -> ( Model, Cmd FrontendMsg )
getRandomProbabilities model k =
    let
        ( randomProbabilities, randomSeed ) =
            Random.step (Random.list k (Random.float 0 1)) model.randomSeed
    in
    ( { model
        | randomProbabilities = randomProbabilities
        , randomSeed = randomSeed
      }
    , Cmd.none
    )


setupWindow : Cmd FrontendMsg
setupWindow =
    Task.perform GotViewport Browser.Dom.getViewport


getStopExpression model =
    --model.inputStopExpression
    --    |> Notebook.Eval.evaluateExpressionStringWithState model.state
    --    |> Eval.eval
    --    |> Result.toMaybe
    Nothing


shorten name =
    case String.split "/" name of
        [ a, b ] ->
            b

        _ ->
            name
