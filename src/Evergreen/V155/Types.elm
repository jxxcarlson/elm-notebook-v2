module Evergreen.V155.Types exposing (..)

import BiDict
import Browser
import Browser.Dom
import Browser.Navigation
import Dict
import Evergreen.V155.Authentication
import Evergreen.V155.Notebook.Book
import Evergreen.V155.Notebook.Cell
import Evergreen.V155.Notebook.DataSet
import Evergreen.V155.Notebook.Types
import Evergreen.V155.Session
import Evergreen.V155.User
import File
import Http
import Keyboard
import Lamdera
import Loading
import Random
import Time
import Url


type MessageStatus
    = MSWhite
    | MSYellow
    | MSBlue
    | MSRed


type alias Message =
    { id : Int
    , txt : String
    , status : MessageStatus
    }


type AppState
    = Loading
    | Loaded


type AppMode
    = AMWorking
    | AMEditTitle


type ClockState
    = ClockRunning
    | ClockStopped
    | ClockPaused


type alias PackageDict =
    Dict.Dict String Evergreen.V155.Notebook.Types.ElmPackageSummary


type DeleteNotebookState
    = WaitingToDeleteNotebook
    | CanDeleteNotebook


type ShowNotebooks
    = ShowUserNotebooks
    | ShowPublicNotebooks


type SignupState
    = ShowSignUpForm
    | HideSignUpForm


type PopupState
    = NoPopup
    | AdminPopup
    | ManualPopup
    | NewDataSetPopup
    | EditDataSetPopup Evergreen.V155.Notebook.DataSet.DataSetMetaData
    | SignUpPopup
    | PackageListPopup
    | CLIPopup
    | NewNotebookPopup
    | StateEditorPopup
    | ViewPublicDataSetsPopup
    | ViewPrivateDataSetsPopup


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , url : Url.Url
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
    , users : List Evergreen.V155.User.User
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
    , publicDataSetMetaDataList : List Evergreen.V155.Notebook.DataSet.DataSetMetaData
    , privateDataSetMetaDataList : List Evergreen.V155.Notebook.DataSet.DataSetMetaData
    , spinnerState : Loading.LoadingState
    , includedCells : List Evergreen.V155.Notebook.Cell.Cell
    , errorReports : List Evergreen.V155.Notebook.Types.ErrorReport
    , showErrorPanel : Bool
    , theme : Evergreen.V155.Notebook.Book.Theme
    , evalState : Evergreen.V155.Notebook.Types.EvalState
    , packagesFromCompiler :
        List
            { name : String
            , version : String
            }
    , packageDict : PackageDict
    , elmJsonError : Maybe String
    , kvDict : Dict.Dict String String
    , books : List Evergreen.V155.Notebook.Book.Book
    , currentCell : Maybe Evergreen.V155.Notebook.Cell.Cell
    , cellInsertionDirection : Evergreen.V155.Notebook.Types.CellDirection
    , currentBook : Evergreen.V155.Notebook.Book.Book
    , cellContent : String
    , currentCellIndex : Int
    , cloneReference : String
    , deleteNotebookState : DeleteNotebookState
    , showNotebooks : ShowNotebooks
    , signupState : SignupState
    , currentUser : Maybe Evergreen.V155.User.User
    , inputUsername : String
    , inputSignupUsername : String
    , inputEmail : String
    , inputRealname : String
    , inputPassword : String
    , inputPasswordAgain : String
    , inputTitle : String
    , windowWidth : Int
    , windowHeight : Int
    , popupState : PopupState
    , showEditor : Bool
    }


type alias Username =
    String


type alias NoteBookDict =
    Dict.Dict String Evergreen.V155.Notebook.Book.Book


type alias UserToNotebookDict =
    Dict.Dict Username NoteBookDict


type alias UsernameToPackageDictDict =
    Dict.Dict String PackageDict


type alias NotebookRecord =
    { id : String
    , author : String
    , public : Bool
    }


type alias BackendModel =
    { currentTime : Time.Posix
    , randomSeed : Random.Seed
    , uuidCount : Int
    , uuid : String
    , randomAtmosphericInt : Maybe Int
    , dataSetLibrary : Dict.Dict String Evergreen.V155.Notebook.DataSet.DataSet
    , userToNoteBookDict : UserToNotebookDict
    , usernameToPackageDictDict : UsernameToPackageDictDict
    , slugDict : Dict.Dict String NotebookRecord
    , sessions : BiDict.BiDict String String
    , sessionInfo : Evergreen.V155.Session.SessionInfo
    , authenticationDict : Evergreen.V155.Authentication.AuthenticationDict
    }


type DataSetDescription
    = PublicDatasets
    | UserDatasets String


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | NoOpFrontendMsg
    | CopyTextToClipboard String
    | FETick Time.Posix
    | KeyboardMsg Keyboard.Msg
    | GetRandomProbabilities Int
    | GotRandomProbabilities (List Float)
    | StringDataRequested Int String
    | StringDataSelected Int String File.File
    | StringDataLoaded String Int String String
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
    | SendProgramToBeCompiled
    | GotCompiledProgram (Result Http.Error String)
    | ToggleTheme Evergreen.V155.Notebook.Book.Theme
    | ExecuteDelayedFunction
    | ExecuteDelayedFunction2
    | ExecuteDelayedMessageRemoval Int
    | GetPackagesFromCompiler
    | GotPackagesFromCompiler (Result Http.Error (List Evergreen.V155.Notebook.Types.SimplePackageInfo))
    | GotElmJsonDict (Result Http.Error Evergreen.V155.Notebook.Types.ElmPackageSummary)
    | GotReplyFromCompiler Evergreen.V155.Notebook.Cell.Cell (Result Http.Error String)
    | ReceivedFromJS String
    | ReceiveJSData String
    | AskToListDataSets DataSetDescription
    | AskToSaveDataSet Evergreen.V155.Notebook.DataSet.DataSetMetaData
    | AskToCreateDataSet
    | AskToDeleteDataSet Evergreen.V155.Notebook.DataSet.DataSetMetaData
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
    | ToggleCellLock Evergreen.V155.Notebook.Cell.Cell
    | ChangeCellInsertionDirection Evergreen.V155.Notebook.Types.CellDirection
    | NewCodeCell Evergreen.V155.Notebook.Cell.CellState Int
    | NewMarkdownCell Evergreen.V155.Notebook.Cell.CellState Int
    | ToggleShowErrorPanel
    | DeleteCell Int
    | MoveCell Int Evergreen.V155.Notebook.Book.DirectionToMove
    | SetCellType Evergreen.V155.Notebook.Cell.Cell Evergreen.V155.Notebook.Cell.CellType
    | SetCellState Evergreen.V155.Notebook.Cell.Cell Evergreen.V155.Notebook.Cell.CellState
    | ToggleComment Bool Int
    | EditCell Evergreen.V155.Notebook.Cell.Cell
    | ClearCell Int
    | EvalCell Evergreen.V155.Notebook.Cell.CellState Int
    | MakeCellCurrent Evergreen.V155.Notebook.Cell.Cell
    | InputElmCode Int String
    | UpdateNotebookTitle
    | NewNotebook
    | ProposeDeletingNotebook
    | CancelDeleteNotebook
    | ChangeAppMode AppMode
    | SetClock ClockState
    | Reset
    | TogglePublic
    | SetCurrentNotebook Evergreen.V155.Notebook.Book.Book
    | CloneNotebook
    | PullNotebook
    | ExportNotebook
    | SetShowNotebooksState ShowNotebooks
    | DuplicateNotebook
    | ImportRequested
    | ImportSelected File.File
    | ImportLoaded String
    | ChangePopup PopupState
    | GotViewport Browser.Dom.Viewport
    | GotNewWindowDimensions Int Int
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
    | AdminRunTask
    | GetUsers


type ToBackend
    = NoOpToBackend
    | GetRandomSeed
    | RunTask
    | SendUsers
    | DeleteDataSet Evergreen.V155.Notebook.DataSet.DataSetMetaData
    | SaveDataSet Evergreen.V155.Notebook.DataSet.DataSetMetaData
    | GetListOfDataSets DataSetDescription
    | CreateDataSet Evergreen.V155.Notebook.DataSet.DataSet
    | GetData Int String String
    | GetDataSetForDownload String
    | GetCellsToInclude (List String)
    | SaveElmJsonDependenciesBE String PackageDict
    | CreateNotebook String String
    | ImportNewBook String Evergreen.V155.Notebook.Book.Book
    | SaveNotebook Evergreen.V155.Notebook.Book.Book
    | DeleteNotebook Evergreen.V155.Notebook.Book.Book
    | GetPublicNotebook String
    | GetClonedNotebook String String String
    | GetPulledNotebook String String String String
    | UpdateSlugDict Evergreen.V155.Notebook.Book.Book
    | GetUsersNotebooks String
    | GetPublicNotebooks (Maybe Evergreen.V155.Notebook.Book.Book) String
    | SignUpBE String String String
    | SignInBEDev
    | SignInBE String String
    | SignOutBE (Maybe String)
    | UpdateUserWith Evergreen.V155.User.User


type BackendMsg
    = NoOpBackendMsg
    | Tick Time.Posix
    | OnConnected String String


type ToFrontend
    = NoOpToFrontend
    | MessageReceived Message
    | GotRandomSeed Random.Seed
    | GotUsers (List Evergreen.V155.User.User)
    | GotListOfPublicDataSets (List Evergreen.V155.Notebook.DataSet.DataSetMetaData)
    | GotListOfPrivateDataSets (List Evergreen.V155.Notebook.DataSet.DataSetMetaData)
    | GotData Int String Evergreen.V155.Notebook.DataSet.DataSet
    | GotDataForDownload Evergreen.V155.Notebook.DataSet.DataSet
    | GotCellsToInclude (List Evergreen.V155.Notebook.Cell.Cell)
    | GotPackageDict PackageDict
    | GotNotebook Evergreen.V155.Notebook.Book.Book
    | GotPublicNotebook Evergreen.V155.Notebook.Book.Book
    | GotNotebooks (Maybe Evergreen.V155.Notebook.Book.Book) (List Evergreen.V155.Notebook.Book.Book)
    | SendMessage String
    | UserSignedIn Evergreen.V155.User.User Lamdera.ClientId
    | SendUser Evergreen.V155.User.User
