module Types exposing (..)

import Authentication exposing (AuthenticationDict)
import BiDict
import Browser exposing (UrlRequest)
import Browser.Dom
import Browser.Navigation exposing (Key)
import Dict exposing (Dict)
import File exposing (File)
import Http
import Json.Encode as Encode
import Keyboard
import Lamdera exposing (ClientId)
import Loading as Spinner
import Notebook.Book exposing (Book, DirectionToMove(..))
import Notebook.Cell exposing (Cell, CellState(..), CellValue(..))
import Notebook.DataSet
import Notebook.Types
import Random
import Session
import Time
import Url exposing (Url)
import User exposing (User)


type alias FrontendModel =
    { -- SYSTEM
      key : Key
    , url : Url
    , messages : List Message
    , appState : AppState
    , appMode : AppMode
    , currentTime : Time.Posix
    , tickCount : Int
    , clockState : ClockState
    , pressedKeys : List Keyboard.Key
    , randomSeed : Random.Seed
    , randomProbabilities : List Float
    , probabilityVectorLength : Int
    , messageId : Int

    -- ADMIN
    , users : List User

    -- INPUT FIELDS
    , inputName : String
    , inputSearch : String
    , inputIdentifier : String
    , inputAuthor : String
    , inputDescription : String
    , inputComments : String
    , inputData : String
    , inputCommand : String
    , inputPackages : String
    , inputInitialStateValue : String

    -- DATA
    , publicDataSetMetaDataList : List Notebook.DataSet.DataSetMetaData
    , privateDataSetMetaDataList : List Notebook.DataSet.DataSetMetaData

    -- NOTEBOOKS
    , spinnerState : Spinner.LoadingState
    , includedCells : List Cell
    , errorReports : List Notebook.Types.ErrorReport
    , showErrorPanel : Bool
    , theme : Notebook.Book.Theme
    , evalState : Notebook.Types.EvalState
    , packagesFromCompiler : List { name : String, version : String }
    , packageDict : PackageDict
    , elmJsonError : Maybe String
    , kvDict : Dict String String
    , books : List Book
    , currentCell : Maybe Cell
    , cellInsertionDirection : Notebook.Types.CellDirection
    , currentBook : Book
    , cellContent : String
    , currentCellIndex : Int
    , cloneReference : String
    , deleteNotebookState : DeleteNotebookState
    , showNotebooks : ShowNotebooks

    -- USER
    , signupState : SignupState
    , currentUser : Maybe User
    , inputUsername : String
    , inputSignupUsername : String
    , inputEmail : String
    , inputRealname : String
    , inputPassword : String
    , inputPasswordAgain : String
    , inputTitle : String

    -- UI
    , windowWidth : Int
    , windowHeight : Int
    , popupState : PopupState
    , showEditor : Bool
    }


type ClockState
    = ClockRunning
    | ClockStopped
    | ClockPaused


type alias BackendModel =
    { currentTime : Time.Posix

    -- RANDOM
    , randomSeed : Random.Seed
    , uuidCount : Int
    , uuid : String
    , randomAtmosphericInt : Maybe Int

    -- NOTEBOOK
    , dataSetLibrary : Dict String Notebook.DataSet.DataSet
    , userToNoteBookDict : UserToNotebookDict -- keys are usernames, values are notebookDicts (keys are notebook ids, values are notebooks)
    , usernameToPackageDictDict : UsernameToPackageDictDict
    , slugDict : Dict.Dict String NotebookRecord -- keys are slugs, values are notebook records

    -- USER
    , sessions : BiDict.BiDict String String -- sessionId to username
    , sessionInfo : Session.SessionInfo
    , authenticationDict : AuthenticationDict

    -- DOCUMENT
    }


type alias PackageDict =
    -- keys = package name
    -- values = ElmPackageSummary
    -- user's elm.json dependencies
    Dict String Notebook.Types.ElmPackageSummary


type alias UsernameToPackageDictDict =
    -- keys = username
    -- values = DictPackageNameToElmPackageSummary
    -- user to store user's elm.json dependencies
    Dict String PackageDict


type ShowNotebooks
    = ShowUserNotebooks
    | ShowPublicNotebooks


type DeleteNotebookState
    = WaitingToDeleteNotebook
    | CanDeleteNotebook


type alias NotebookRecord =
    { id : String, author : String, public : Bool }


type FrontendMsg
    = UrlClicked UrlRequest
    | UrlChanged Url
    | NoOpFrontendMsg
    | CopyTextToClipboard String
    | FETick Time.Posix
    | KeyboardMsg Keyboard.Msg
    | GetRandomProbabilities Int
    | GotRandomProbabilities (List Float)
      -- FILE
    | StringDataRequested Int String -- int is the cell index, string is the variable name
    | StringDataSelected Int String File
    | StringDataLoaded String Int String String
      -- INPUT FIELDS
    | InputName String
    | InputSearch String
    | InputIdentifier String
    | InputDescription String
    | InputComments String
    | InputData String
    | InputCommand String
    | InputPackages String
    | InputAuthor String
    | InputInitialStateValue String
      -- Compile program
    | SendProgramToBeCompiled
    | GotCompiledProgram (Result Http.Error String)
      -- Notebook
    | ToggleTheme Notebook.Book.Theme
    | ExecuteDelayedFunction
    | ExecuteDelayedFunction2
    | ExecuteDelayedMessageRemoval Int
    | GetPackagesFromCompiler
    | GotPackagesFromCompiler (Result Http.Error (List Notebook.Types.SimplePackageInfo))
    | GotElmJsonDict (Result Http.Error Notebook.Types.ElmPackageSummary)
    | GotReplyFromCompiler Cell (Result Http.Error String)
    | ReceivedFromJS String
    | ReceiveJSData String
      -- DATA
    | AskToListDataSets DataSetDescription
    | AskToSaveDataSet Notebook.DataSet.DataSetMetaData
    | AskToCreateDataSet
    | AskToDeleteDataSet Notebook.DataSet.DataSetMetaData
      -- CELL
    | SubmitPackageList
    | SubmitTest
    | RunCommand
    | PackageListSent (Result Http.Error String)
    | ClearNotebookValues
    | ExecuteNotebook
    | UpdateDeclarationsDictionary
    | ExecuteCell Int
    | ExecuteCells (Result Http.Error (List ( Int, String )))
    | UpdateErrorReports
    | FetchDependencies String
    | ToggleCellLock Cell
    | ChangeCellInsertionDirection Notebook.Types.CellDirection
    | NewCodeCell CellState Int
    | NewMarkdownCell CellState Int
    | ToggleShowErrorPanel
    | DeleteCell Int
    | MoveCell Int DirectionToMove
    | SetCellType Cell Notebook.Cell.CellType
    | SetCellState Cell Notebook.Cell.CellState
    | ToggleComment Bool Int
    | EditCell Cell
    | ClearCell Int
    | EvalCell CellState Int
    | MakeCellCurrent Cell
    | InputElmCode Int String
    | UpdateNotebookTitle
    | NewNotebook
    | ProposeDeletingNotebook
    | CancelDeleteNotebook
    | ChangeAppMode AppMode
    | SetClock ClockState
    | Reset
    | TogglePublic
    | SetCurrentNotebook Book
    | CloneNotebook
    | PullNotebook
    | ExportNotebook
    | SetShowNotebooksState ShowNotebooks
    | DuplicateNotebook
    | ImportRequested
    | ImportSelected File
    | ImportLoaded String
      -- UI
    | ChangePopup PopupState
    | GotViewport Browser.Dom.Viewport
    | GotNewWindowDimensions Int Int
      -- USER
    | SignUp
    | SignIn
    | SignOut
    | SetSignupState SignupState
    | InputUsername String
    | InputSignupUsername String
    | InputPassword String
    | InputPasswordAgain String
    | InputEmail String
    | InputTitle String
    | InputCloneReference String
      -- ADMIN
    | AdminRunTask
    | GetUsers


type Command
    = XCell Int


type alias Message =
    { id : Int, txt : String, status : MessageStatus }


type DataSetDescription
    = PublicDatasets
    | UserDatasets String


type MessageStatus
    = MSWhite
    | MSYellow
    | MSBlue
    | MSRed


type PopupState
    = NoPopup
    | AdminPopup
    | ManualPopup
    | NewDataSetPopup
    | EditDataSetPopup Notebook.DataSet.DataSetMetaData
    | SignUpPopup
    | PackageListPopup
    | CLIPopup
    | NewNotebookPopup
    | StateEditorPopup
    | ViewPublicDataSetsPopup
    | ViewPrivateDataSetsPopup


type SearchTerm
    = Query String


type ToBackend
    = NoOpToBackend
    | GetRandomSeed
      -- ADMIN
    | RunTask
    | SendUsers
      -- DATA
    | DeleteDataSet Notebook.DataSet.DataSetMetaData
    | SaveDataSet Notebook.DataSet.DataSetMetaData
    | GetListOfDataSets DataSetDescription
    | CreateDataSet Notebook.DataSet.DataSet
    | GetData Int String String -- Int is the index of the requesting cell,
      -- String1 is the DataSet identifier, String2 is the variable in which to store it.
    | GetDataSetForDownload String -- Int is the index of the requesting cell,
      -- NOTEBOOK
    | GetCellsToInclude (List String)
    | SaveElmJsonDependenciesBE String PackageDict
    | CreateNotebook String String -- authorname title
    | ImportNewBook String Book
    | SaveNotebook Book
    | DeleteNotebook Book
    | GetPublicNotebook String
    | GetClonedNotebook String String String -- (username of currentUser) (author of book to clone) (id of book to clone)
    | GetPulledNotebook String String String String -- username origin slug id
    | UpdateSlugDict Book
    | GetUsersNotebooks String -- username
    | GetPublicNotebooks (Maybe Book) String --
      -- USER
    | SignUpBE String String String
    | SignInBEDev
    | SignInBE String String
    | SignOutBE (Maybe String)
    | UpdateUserWith User


type BackendMsg
    = NoOpBackendMsg
    | Tick Time.Posix
    | OnConnected String String


type ToFrontend
    = NoOpToFrontend
    | MessageReceived Message
    | GotRandomSeed Random.Seed
      -- ADMIN
    | GotUsers (List User)
      -- DATA
    | GotListOfPublicDataSets (List Notebook.DataSet.DataSetMetaData)
    | GotListOfPrivateDataSets (List Notebook.DataSet.DataSetMetaData)
    | GotData Int String Notebook.DataSet.DataSet
    | GotDataForDownload Notebook.DataSet.DataSet
      -- NOTEBOOK
    | GotCellsToInclude (List Cell)
    | GotPackageDict PackageDict
    | GotNotebook Book
    | GotPublicNotebook Book
    | GotNotebooks (Maybe Book) (List Book)
      -- USER
    | SendMessage String
    | UserSignedIn User ClientId
    | SendUser User


type AppState
    = Loading
    | Loaded


type AppMode
    = AMWorking
    | AMEditTitle


type SignupState
    = ShowSignUpForm
    | HideSignUpForm


type alias Username =
    String


{-| Keys are notebook ids
-}
type alias NoteBookDict =
    Dict.Dict String Book


{-| UserToNotebookDict is the master dictionary for all notebooks
-}
type alias UserToNotebookDict =
    Dict.Dict Username NoteBookDict


type DeleteItemState
    = WaitingToDeleteItem
    | CanDeleteItem (Maybe String)
