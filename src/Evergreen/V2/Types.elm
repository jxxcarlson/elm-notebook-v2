module Evergreen.V2.Types exposing (..)

import Browser
import Browser.Dom
import Browser.Navigation
import Dict
import Evergreen.V2.Authentication
import Evergreen.V2.Notebook.Book
import Evergreen.V2.Notebook.Cell
import Evergreen.V2.Notebook.DataSet
import Evergreen.V2.Notebook.Types
import Evergreen.V2.User
import File
import Http
import Keyboard
import Lamdera
import Random
import Time
import Url


type MessageStatus
    = MSWhite
    | MSYellow
    | MSGreen
    | MSRed


type alias Message =
    { txt : String
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


type alias DictPackageNameToElmPackageSummary =
    Dict.Dict String Evergreen.V2.Notebook.Types.ElmPackageSummary


type alias DictNoteBookIdsToElmPackageSummaryDict =
    Dict.Dict String DictPackageNameToElmPackageSummary


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
    | EditDataSetPopup Evergreen.V2.Notebook.DataSet.DataSetMetaData
    | SignUpPopup
    | PackageListPopup
    | NewNotebookPopup
    | StateEditorPopup
    | ViewPublicDataSetsPopup
    | ViewPrivateDataSetsPopup


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , url : Url.Url
    , message : String
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
    , users : List Evergreen.V2.User.User
    , inputName : String
    , inputIdentifier : String
    , inputAuthor : String
    , inputDescription : String
    , inputComments : String
    , inputData : String
    , inputPackages : String
    , inputInitialStateValue : String
    , publicDataSetMetaDataList : List Evergreen.V2.Notebook.DataSet.DataSetMetaData
    , privateDataSetMetaDataList : List Evergreen.V2.Notebook.DataSet.DataSetMetaData
    , evalState : Evergreen.V2.Notebook.Types.EvalState
    , notebookIdsToElmPackageSummaryDict : DictNoteBookIdsToElmPackageSummaryDict
    , currentElmJsonDependencies : DictPackageNameToElmPackageSummary
    , elmJsonError : Maybe String
    , kvDict : Dict.Dict String String
    , books : List Evergreen.V2.Notebook.Book.Book
    , currentCell : Maybe Evergreen.V2.Notebook.Cell.Cell
    , cellInsertionDirection : Evergreen.V2.Notebook.Types.CellDirection
    , currentBook : Evergreen.V2.Notebook.Book.Book
    , cellContent : String
    , currentCellIndex : Int
    , cloneReference : String
    , deleteNotebookState : DeleteNotebookState
    , showNotebooks : ShowNotebooks
    , signupState : SignupState
    , currentUser : Maybe Evergreen.V2.User.User
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
    Dict.Dict String Evergreen.V2.Notebook.Book.Book


type alias UserToNotebookDict =
    Dict.Dict Username NoteBookDict


type alias DictUsernameToDictNoteBookIdsToElmPackageSummaryDict =
    Dict.Dict String DictNoteBookIdsToElmPackageSummaryDict


type alias NotebookRecord =
    { id : String
    , author : String
    , public : Bool
    }


type alias BackendModel =
    { message : String
    , currentTime : Time.Posix
    , randomSeed : Random.Seed
    , uuidCount : Int
    , uuid : String
    , randomAtmosphericInt : Maybe Int
    , dataSetLibrary : Dict.Dict String Evergreen.V2.Notebook.DataSet.DataSet
    , userToNoteBookDict : UserToNotebookDict
    , usernameToNotebookPackageSummaryDict : DictUsernameToDictNoteBookIdsToElmPackageSummaryDict
    , slugDict : Dict.Dict String NotebookRecord
    , authenticationDict : Evergreen.V2.Authentication.AuthenticationDict
    }


type DataSetDescription
    = PublicDatasets
    | UserDatasets String


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | NoOpFrontendMsg
    | FETick Time.Posix
    | KeyboardMsg Keyboard.Msg
    | GetRandomProbabilities Int
    | GotRandomProbabilities (List Float)
    | StringDataRequested Int String
    | StringDataSelected Int String File.File
    | StringDataLoaded String Int String String
    | InputName String
    | InputIdentifier String
    | InputDescription String
    | InputComments String
    | InputData String
    | InputPackages String
    | InputAuthor String
    | InputInitialStateValue String
    | ExecuteDelayedFunction
    | GotElmJsonDict (Result Http.Error Evergreen.V2.Notebook.Types.ElmPackageSummary)
    | GotReply Evergreen.V2.Notebook.Cell.Cell (Result Http.Error String)
    | ReceivedFromJS String
    | AskToListDataSets DataSetDescription
    | AskToSaveDataSet Evergreen.V2.Notebook.DataSet.DataSetMetaData
    | AskToCreateDataSet
    | AskToDeleteDataSet Evergreen.V2.Notebook.DataSet.DataSetMetaData
    | SubmitPackageList
    | SubmitTest
    | PackageListSent (Result Http.Error String)
    | ClearNotebookValues
    | ExecuteNotebook
    | UpdateDeclarationsDictionary
    | ExecuteCell Int
    | FetchDependencies String
    | ToggleCellLock Evergreen.V2.Notebook.Cell.Cell
    | ChangeCellInsertionDirection Evergreen.V2.Notebook.Types.CellDirection
    | NewCodeCell Evergreen.V2.Notebook.Cell.CellState Int
    | NewMarkdownCell Evergreen.V2.Notebook.Cell.CellState Int
    | DeleteCell Int
    | EditCell Evergreen.V2.Notebook.Cell.Cell
    | ClearCell Int
    | EvalCell Evergreen.V2.Notebook.Cell.CellState Int
    | InputElmCode Int String
    | UpdateNotebookTitle
    | NewNotebook
    | ProposeDeletingNotebook
    | CancelDeleteNotebook
    | ChangeAppMode AppMode
    | SetClock ClockState
    | Reset
    | TogglePublic
    | SetCurrentNotebook Evergreen.V2.Notebook.Book.Book
    | CloneNotebook
    | PullNotebook
    | ExportNotebook
    | SetShowNotebooksState ShowNotebooks
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
    | DeleteDataSet Evergreen.V2.Notebook.DataSet.DataSetMetaData
    | SaveDataSet Evergreen.V2.Notebook.DataSet.DataSetMetaData
    | GetListOfDataSets DataSetDescription
    | CreateDataSet Evergreen.V2.Notebook.DataSet.DataSet
    | GetData Int String String
    | GetDataSetForDownload String
    | SaveElmJsonDependenciesBE String DictNoteBookIdsToElmPackageSummaryDict
    | CreateNotebook String String
    | ImportNewBook String Evergreen.V2.Notebook.Book.Book
    | SaveNotebook Evergreen.V2.Notebook.Book.Book
    | DeleteNotebook Evergreen.V2.Notebook.Book.Book
    | GetPublicNotebook String
    | GetClonedNotebook String String
    | GetPulledNotebook String String String String
    | UpdateSlugDict Evergreen.V2.Notebook.Book.Book
    | GetUsersNotebooks String
    | GetPublicNotebooks (Maybe Evergreen.V2.Notebook.Book.Book) String
    | SignUpBE String String String
    | SignInBEDev
    | SignInBE String String
    | SignOutBE (Maybe String)
    | UpdateUserWith Evergreen.V2.User.User


type BackendMsg
    = NoOpBackendMsg
    | Tick Time.Posix


type ToFrontend
    = NoOpToFrontend
    | MessageReceived Message
    | GotRandomSeed Random.Seed
    | GotUsers (List Evergreen.V2.User.User)
    | GotListOfPublicDataSets (List Evergreen.V2.Notebook.DataSet.DataSetMetaData)
    | GotListOfPrivateDataSets (List Evergreen.V2.Notebook.DataSet.DataSetMetaData)
    | GotData Int String Evergreen.V2.Notebook.DataSet.DataSet
    | GotDataForDownload Evergreen.V2.Notebook.DataSet.DataSet
    | GotUsersPackageDictInfo DictNoteBookIdsToElmPackageSummaryDict
    | GotNotebook Evergreen.V2.Notebook.Book.Book
    | GotPublicNotebook Evergreen.V2.Notebook.Book.Book
    | GotNotebooks (Maybe Evergreen.V2.Notebook.Book.Book) (List Evergreen.V2.Notebook.Book.Book)
    | SendMessage String
    | UserSignedIn Evergreen.V2.User.User Lamdera.ClientId
    | SendUser Evergreen.V2.User.User
