module Evergreen.Migrate.V155 exposing (..)

{-| This migration file was automatically generated by the lamdera compiler.

It includes:

  - A migration for each of the 6 Lamdera core types that has changed
  - A function named `migrate_ModuleName_TypeName` for each changed/custom type

Expect to see:

  - `Unimplementеd` values as placeholders wherever I was unable to figure out a clear migration path for you
  - `@NOTICE` comments for things you should know about, i.e. new custom type constructors that won't get any
    value mappings from the old type by default

You can edit this file however you wish! It won't be generated again.

See <https://dashboard.lamdera.app/docs/evergreen> for more info.

-}

import Evergreen.V151.Notebook.Book
import Evergreen.V151.Notebook.Cell
import Evergreen.V151.Notebook.DataSet
import Evergreen.V151.Notebook.Types
import Evergreen.V151.Types
import Evergreen.V155.Notebook.Book
import Evergreen.V155.Notebook.Cell
import Evergreen.V155.Notebook.DataSet
import Evergreen.V155.Notebook.Types
import Evergreen.V155.Types
import Lamdera.Migrations exposing (..)
import List
import Loading
import Maybe


frontendModel : Evergreen.V151.Types.FrontendModel -> ModelMigration Evergreen.V155.Types.FrontendModel Evergreen.V155.Types.FrontendMsg
frontendModel old =
    ModelMigrated ( migrate_Types_FrontendModel old, Cmd.none )


backendModel : Evergreen.V151.Types.BackendModel -> ModelMigration Evergreen.V155.Types.BackendModel Evergreen.V155.Types.BackendMsg
backendModel old =
    ModelUnchanged


frontendMsg : Evergreen.V151.Types.FrontendMsg -> MsgMigration Evergreen.V155.Types.FrontendMsg Evergreen.V155.Types.FrontendMsg
frontendMsg old =
    MsgUnchanged


toBackend : Evergreen.V151.Types.ToBackend -> MsgMigration Evergreen.V155.Types.ToBackend Evergreen.V155.Types.BackendMsg
toBackend old =
    MsgUnchanged


backendMsg : Evergreen.V151.Types.BackendMsg -> MsgMigration Evergreen.V155.Types.BackendMsg Evergreen.V155.Types.BackendMsg
backendMsg old =
    MsgUnchanged


toFrontend : Evergreen.V151.Types.ToFrontend -> MsgMigration Evergreen.V155.Types.ToFrontend Evergreen.V155.Types.FrontendMsg
toFrontend old =
    MsgUnchanged


migrate_Types_FrontendModel : Evergreen.V151.Types.FrontendModel -> Evergreen.V155.Types.FrontendModel
migrate_Types_FrontendModel old =
    { key = old.key
    , url = old.url
    , messages = old.messages |> List.map migrate_Types_Message
    , appState = old.appState |> migrate_Types_AppState
    , appMode = old.appMode |> migrate_Types_AppMode
    , currentTime = old.currentTime
    , tickCount = old.tickCount
    , clockState = old.clockState |> migrate_Types_ClockState
    , pressedKeys = old.pressedKeys
    , randomSeed = old.randomSeed
    , randomProbabilities = old.randomProbabilities
    , probabilityVectorLength = old.probabilityVectorLength
    , messageId = old.messageId
    , users = old.users
    , inputName = old.inputName
    , inputSearch = old.inputSearch
    , inputIdentifier = old.inputIdentifier
    , inputAuthor = old.inputAuthor
    , inputDescription = old.inputDescription
    , inputComments = old.inputComments
    , inputData = old.inputData
    , inputCommand = old.inputCommand
    , inputPackages = old.inputPackages
    , inputInitialStateValue = old.inputInitialStateValue
    , publicDataSetMetaDataList = old.publicDataSetMetaDataList
    , privateDataSetMetaDataList = old.privateDataSetMetaDataList
    , spinnerState = Loading.Off
    , includedCells = old.includedCells |> List.map migrate_Notebook_Cell_Cell
    , errorReports = old.errorReports |> List.map migrate_Notebook_Types_ErrorReport
    , showErrorPanel = old.showErrorPanel
    , theme = old.theme |> migrate_Notebook_Book_Theme
    , evalState = old.evalState |> migrate_Notebook_Types_EvalState
    , packagesFromCompiler = old.packagesFromCompiler
    , packageDict = old.packageDict
    , elmJsonError = old.elmJsonError
    , kvDict = old.kvDict
    , books = old.books |> List.map migrate_Notebook_Book_Book
    , currentCell = old.currentCell |> Maybe.map migrate_Notebook_Cell_Cell
    , cellInsertionDirection = old.cellInsertionDirection |> migrate_Notebook_Types_CellDirection
    , currentBook = old.currentBook |> migrate_Notebook_Book_Book
    , cellContent = old.cellContent
    , currentCellIndex = old.currentCellIndex
    , cloneReference = old.cloneReference
    , deleteNotebookState = old.deleteNotebookState |> migrate_Types_DeleteNotebookState
    , showNotebooks = old.showNotebooks |> migrate_Types_ShowNotebooks
    , signupState = old.signupState |> migrate_Types_SignupState
    , currentUser = old.currentUser
    , inputUsername = old.inputUsername
    , inputSignupUsername = old.inputSignupUsername
    , inputEmail = old.inputEmail
    , inputRealname = old.inputRealname
    , inputPassword = old.inputPassword
    , inputPasswordAgain = old.inputPasswordAgain
    , inputTitle = old.inputTitle
    , windowWidth = old.windowWidth
    , windowHeight = old.windowHeight
    , popupState = old.popupState |> migrate_Types_PopupState
    , showEditor = old.showEditor
    }


migrate_Notebook_Book_Book : Evergreen.V151.Notebook.Book.Book -> Evergreen.V155.Notebook.Book.Book
migrate_Notebook_Book_Book old =
    { id = old.id
    , dirty = old.dirty
    , slug = old.slug
    , origin = old.origin
    , author = old.author
    , createdAt = old.createdAt
    , updatedAt = old.updatedAt
    , public = old.public
    , title = old.title
    , cells = old.cells |> List.map migrate_Notebook_Cell_Cell
    , currentIndex = old.currentIndex
    , packageNames = old.packageNames
    , tags = old.tags
    , options = old.options
    }


migrate_Notebook_Book_Theme : Evergreen.V151.Notebook.Book.Theme -> Evergreen.V155.Notebook.Book.Theme
migrate_Notebook_Book_Theme old =
    case old of
        Evergreen.V151.Notebook.Book.DarkTheme ->
            Evergreen.V155.Notebook.Book.DarkTheme

        Evergreen.V151.Notebook.Book.LightTheme ->
            Evergreen.V155.Notebook.Book.LightTheme


migrate_Notebook_Cell_Cell : Evergreen.V151.Notebook.Cell.Cell -> Evergreen.V155.Notebook.Cell.Cell
migrate_Notebook_Cell_Cell old =
    { index = old.index
    , text = old.text
    , tipe = old.tipe |> migrate_Notebook_Cell_CellType
    , value = old.value |> migrate_Notebook_Cell_CellValue
    , cellState = old.cellState |> migrate_Notebook_Cell_CellState
    , commented = old.commented
    , locked = old.locked
    , report = old.report |> Tuple.mapSecond (Maybe.map (List.map migrate_Notebook_Types_MessageItem))
    , replData = old.replData
    , highlightTime = old.highlightTime
    }


migrate_Notebook_Cell_CellState : Evergreen.V151.Notebook.Cell.CellState -> Evergreen.V155.Notebook.Cell.CellState
migrate_Notebook_Cell_CellState old =
    case old of
        Evergreen.V151.Notebook.Cell.CSEdit ->
            Evergreen.V155.Notebook.Cell.CSEdit

        Evergreen.V151.Notebook.Cell.CSEditCompact ->
            Evergreen.V155.Notebook.Cell.CSEditCompact

        Evergreen.V151.Notebook.Cell.CSView ->
            Evergreen.V155.Notebook.Cell.CSView


migrate_Notebook_Cell_CellType : Evergreen.V151.Notebook.Cell.CellType -> Evergreen.V155.Notebook.Cell.CellType
migrate_Notebook_Cell_CellType old =
    case old of
        Evergreen.V151.Notebook.Cell.CTCode ->
            Evergreen.V155.Notebook.Cell.CTCode

        Evergreen.V151.Notebook.Cell.CTMarkdown ->
            Evergreen.V155.Notebook.Cell.CTMarkdown


migrate_Notebook_Cell_CellValue : Evergreen.V151.Notebook.Cell.CellValue -> Evergreen.V155.Notebook.Cell.CellValue
migrate_Notebook_Cell_CellValue old =
    case old of
        Evergreen.V151.Notebook.Cell.CVString p0 ->
            Evergreen.V155.Notebook.Cell.CVString p0

        Evergreen.V151.Notebook.Cell.CVMarkdown p0 ->
            Evergreen.V155.Notebook.Cell.CVMarkdown p0

        Evergreen.V151.Notebook.Cell.CVNone ->
            Evergreen.V155.Notebook.Cell.CVNone


migrate_Notebook_DataSet_DataSetMetaData : Evergreen.V151.Notebook.DataSet.DataSetMetaData -> Evergreen.V155.Notebook.DataSet.DataSetMetaData
migrate_Notebook_DataSet_DataSetMetaData old =
    old


migrate_Notebook_Types_CellDirection : Evergreen.V151.Notebook.Types.CellDirection -> Evergreen.V155.Notebook.Types.CellDirection
migrate_Notebook_Types_CellDirection old =
    case old of
        Evergreen.V151.Notebook.Types.Up ->
            Evergreen.V155.Notebook.Types.Up

        Evergreen.V151.Notebook.Types.Down ->
            Evergreen.V155.Notebook.Types.Down


migrate_Notebook_Types_ErrorReport : Evergreen.V151.Notebook.Types.ErrorReport -> Evergreen.V155.Notebook.Types.ErrorReport
migrate_Notebook_Types_ErrorReport old =
    old |> Tuple.mapSecond (List.map migrate_Notebook_Types_MessageItem)


migrate_Notebook_Types_EvalState : Evergreen.V151.Notebook.Types.EvalState -> Evergreen.V155.Notebook.Types.EvalState
migrate_Notebook_Types_EvalState old =
    old


migrate_Notebook_Types_MessageItem : Evergreen.V151.Notebook.Types.MessageItem -> Evergreen.V155.Notebook.Types.MessageItem
migrate_Notebook_Types_MessageItem old =
    case old of
        Evergreen.V151.Notebook.Types.Plain p0 ->
            Evergreen.V155.Notebook.Types.Plain p0

        Evergreen.V151.Notebook.Types.Styled p0 ->
            Evergreen.V155.Notebook.Types.Styled (p0 |> migrate_Notebook_Types_StyledString)


migrate_Notebook_Types_StyledString : Evergreen.V151.Notebook.Types.StyledString -> Evergreen.V155.Notebook.Types.StyledString
migrate_Notebook_Types_StyledString old =
    old


migrate_Types_AppMode : Evergreen.V151.Types.AppMode -> Evergreen.V155.Types.AppMode
migrate_Types_AppMode old =
    case old of
        Evergreen.V151.Types.AMWorking ->
            Evergreen.V155.Types.AMWorking

        Evergreen.V151.Types.AMEditTitle ->
            Evergreen.V155.Types.AMEditTitle


migrate_Types_AppState : Evergreen.V151.Types.AppState -> Evergreen.V155.Types.AppState
migrate_Types_AppState old =
    case old of
        Evergreen.V151.Types.Loading ->
            Evergreen.V155.Types.Loading

        Evergreen.V151.Types.Loaded ->
            Evergreen.V155.Types.Loaded


migrate_Types_ClockState : Evergreen.V151.Types.ClockState -> Evergreen.V155.Types.ClockState
migrate_Types_ClockState old =
    case old of
        Evergreen.V151.Types.ClockRunning ->
            Evergreen.V155.Types.ClockRunning

        Evergreen.V151.Types.ClockStopped ->
            Evergreen.V155.Types.ClockStopped

        Evergreen.V151.Types.ClockPaused ->
            Evergreen.V155.Types.ClockPaused


migrate_Types_DeleteNotebookState : Evergreen.V151.Types.DeleteNotebookState -> Evergreen.V155.Types.DeleteNotebookState
migrate_Types_DeleteNotebookState old =
    case old of
        Evergreen.V151.Types.WaitingToDeleteNotebook ->
            Evergreen.V155.Types.WaitingToDeleteNotebook

        Evergreen.V151.Types.CanDeleteNotebook ->
            Evergreen.V155.Types.CanDeleteNotebook


migrate_Types_Message : Evergreen.V151.Types.Message -> Evergreen.V155.Types.Message
migrate_Types_Message old =
    { id = old.id
    , txt = old.txt
    , status = old.status |> migrate_Types_MessageStatus
    }


migrate_Types_MessageStatus : Evergreen.V151.Types.MessageStatus -> Evergreen.V155.Types.MessageStatus
migrate_Types_MessageStatus old =
    case old of
        Evergreen.V151.Types.MSWhite ->
            Evergreen.V155.Types.MSWhite

        Evergreen.V151.Types.MSYellow ->
            Evergreen.V155.Types.MSYellow

        Evergreen.V151.Types.MSBlue ->
            Evergreen.V155.Types.MSBlue

        Evergreen.V151.Types.MSRed ->
            Evergreen.V155.Types.MSRed


migrate_Types_PopupState : Evergreen.V151.Types.PopupState -> Evergreen.V155.Types.PopupState
migrate_Types_PopupState old =
    case old of
        Evergreen.V151.Types.NoPopup ->
            Evergreen.V155.Types.NoPopup

        Evergreen.V151.Types.AdminPopup ->
            Evergreen.V155.Types.AdminPopup

        Evergreen.V151.Types.ManualPopup ->
            Evergreen.V155.Types.ManualPopup

        Evergreen.V151.Types.NewDataSetPopup ->
            Evergreen.V155.Types.NewDataSetPopup

        Evergreen.V151.Types.EditDataSetPopup p0 ->
            Evergreen.V155.Types.EditDataSetPopup (p0 |> migrate_Notebook_DataSet_DataSetMetaData)

        Evergreen.V151.Types.SignUpPopup ->
            Evergreen.V155.Types.SignUpPopup

        Evergreen.V151.Types.PackageListPopup ->
            Evergreen.V155.Types.PackageListPopup

        Evergreen.V151.Types.CLIPopup ->
            Evergreen.V155.Types.CLIPopup

        Evergreen.V151.Types.NewNotebookPopup ->
            Evergreen.V155.Types.NewNotebookPopup

        Evergreen.V151.Types.StateEditorPopup ->
            Evergreen.V155.Types.StateEditorPopup

        Evergreen.V151.Types.ViewPublicDataSetsPopup ->
            Evergreen.V155.Types.ViewPublicDataSetsPopup

        Evergreen.V151.Types.ViewPrivateDataSetsPopup ->
            Evergreen.V155.Types.ViewPrivateDataSetsPopup


migrate_Types_ShowNotebooks : Evergreen.V151.Types.ShowNotebooks -> Evergreen.V155.Types.ShowNotebooks
migrate_Types_ShowNotebooks old =
    case old of
        Evergreen.V151.Types.ShowUserNotebooks ->
            Evergreen.V155.Types.ShowUserNotebooks

        Evergreen.V151.Types.ShowPublicNotebooks ->
            Evergreen.V155.Types.ShowPublicNotebooks


migrate_Types_SignupState : Evergreen.V151.Types.SignupState -> Evergreen.V155.Types.SignupState
migrate_Types_SignupState old =
    case old of
        Evergreen.V151.Types.ShowSignUpForm ->
            Evergreen.V155.Types.ShowSignUpForm

        Evergreen.V151.Types.HideSignUpForm ->
            Evergreen.V155.Types.HideSignUpForm