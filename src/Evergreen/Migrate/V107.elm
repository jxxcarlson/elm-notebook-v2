module Evergreen.Migrate.V107 exposing (..)

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

import Evergreen.V107.Notebook.Book
import Evergreen.V107.Notebook.Cell
import Evergreen.V107.Notebook.DataSet
import Evergreen.V107.Notebook.Types
import Evergreen.V107.Types
import Evergreen.V97.Notebook.Book
import Evergreen.V97.Notebook.Cell
import Evergreen.V97.Notebook.DataSet
import Evergreen.V97.Notebook.Types
import Evergreen.V97.Types
import Lamdera.Migrations exposing (..)
import List
import Maybe


frontendModel : Evergreen.V97.Types.FrontendModel -> ModelMigration Evergreen.V107.Types.FrontendModel Evergreen.V107.Types.FrontendMsg
frontendModel old =
    ModelUnchanged


backendModel : Evergreen.V97.Types.BackendModel -> ModelMigration Evergreen.V107.Types.BackendModel Evergreen.V107.Types.BackendMsg
backendModel old =
    ModelUnchanged


frontendMsg : Evergreen.V97.Types.FrontendMsg -> MsgMigration Evergreen.V107.Types.FrontendMsg Evergreen.V107.Types.FrontendMsg
frontendMsg old =
    MsgMigrated ( migrate_Types_FrontendMsg old, Cmd.none )


toBackend : Evergreen.V97.Types.ToBackend -> MsgMigration Evergreen.V107.Types.ToBackend Evergreen.V107.Types.BackendMsg
toBackend old =
    MsgUnchanged


backendMsg : Evergreen.V97.Types.BackendMsg -> MsgMigration Evergreen.V107.Types.BackendMsg Evergreen.V107.Types.BackendMsg
backendMsg old =
    MsgUnchanged


toFrontend : Evergreen.V97.Types.ToFrontend -> MsgMigration Evergreen.V107.Types.ToFrontend Evergreen.V107.Types.FrontendMsg
toFrontend old =
    MsgUnchanged


migrate_Notebook_Book_Book : Evergreen.V97.Notebook.Book.Book -> Evergreen.V107.Notebook.Book.Book
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


migrate_Notebook_Book_DirectionToMove : Evergreen.V97.Notebook.Book.DirectionToMove -> Evergreen.V107.Notebook.Book.DirectionToMove
migrate_Notebook_Book_DirectionToMove old =
    case old of
        Evergreen.V97.Notebook.Book.Up ->
            Evergreen.V107.Notebook.Book.Up

        Evergreen.V97.Notebook.Book.Down ->
            Evergreen.V107.Notebook.Book.Down


migrate_Notebook_Book_Theme : Evergreen.V97.Notebook.Book.Theme -> Evergreen.V107.Notebook.Book.Theme
migrate_Notebook_Book_Theme old =
    case old of
        Evergreen.V97.Notebook.Book.DarkTheme ->
            Evergreen.V107.Notebook.Book.DarkTheme

        Evergreen.V97.Notebook.Book.LightTheme ->
            Evergreen.V107.Notebook.Book.LightTheme


migrate_Notebook_Cell_Cell : Evergreen.V97.Notebook.Cell.Cell -> Evergreen.V107.Notebook.Cell.Cell
migrate_Notebook_Cell_Cell old =
    { index = old.index
    , text = old.text
    , tipe = old.tipe |> migrate_Notebook_Cell_CellType
    , value = old.value |> migrate_Notebook_Cell_CellValue
    , cellState = old.cellState |> migrate_Notebook_Cell_CellState
    , locked = old.locked
    , report = old.report |> Tuple.mapSecond (Maybe.map (List.map migrate_Notebook_Types_MessageItem))
    , replData = old.replData
    }


migrate_Notebook_Cell_CellState : Evergreen.V97.Notebook.Cell.CellState -> Evergreen.V107.Notebook.Cell.CellState
migrate_Notebook_Cell_CellState old =
    case old of
        Evergreen.V97.Notebook.Cell.CSEdit ->
            Evergreen.V107.Notebook.Cell.CSEdit

        Evergreen.V97.Notebook.Cell.CSView ->
            Evergreen.V107.Notebook.Cell.CSView


migrate_Notebook_Cell_CellType : Evergreen.V97.Notebook.Cell.CellType -> Evergreen.V107.Notebook.Cell.CellType
migrate_Notebook_Cell_CellType old =
    case old of
        Evergreen.V97.Notebook.Cell.CTCode ->
            Evergreen.V107.Notebook.Cell.CTCode

        Evergreen.V97.Notebook.Cell.CTMarkdown ->
            Evergreen.V107.Notebook.Cell.CTMarkdown


migrate_Notebook_Cell_CellValue : Evergreen.V97.Notebook.Cell.CellValue -> Evergreen.V107.Notebook.Cell.CellValue
migrate_Notebook_Cell_CellValue old =
    case old of
        Evergreen.V97.Notebook.Cell.CVString p0 ->
            Evergreen.V107.Notebook.Cell.CVString p0

        Evergreen.V97.Notebook.Cell.CVMarkdown p0 ->
            Evergreen.V107.Notebook.Cell.CVMarkdown p0

        Evergreen.V97.Notebook.Cell.CVNone ->
            Evergreen.V107.Notebook.Cell.CVNone


migrate_Notebook_DataSet_DataSetMetaData : Evergreen.V97.Notebook.DataSet.DataSetMetaData -> Evergreen.V107.Notebook.DataSet.DataSetMetaData
migrate_Notebook_DataSet_DataSetMetaData old =
    old


migrate_Notebook_Types_CellDirection : Evergreen.V97.Notebook.Types.CellDirection -> Evergreen.V107.Notebook.Types.CellDirection
migrate_Notebook_Types_CellDirection old =
    case old of
        Evergreen.V97.Notebook.Types.Up ->
            Evergreen.V107.Notebook.Types.Up

        Evergreen.V97.Notebook.Types.Down ->
            Evergreen.V107.Notebook.Types.Down


migrate_Notebook_Types_MessageItem : Evergreen.V97.Notebook.Types.MessageItem -> Evergreen.V107.Notebook.Types.MessageItem
migrate_Notebook_Types_MessageItem old =
    case old of
        Evergreen.V97.Notebook.Types.Plain p0 ->
            Evergreen.V107.Notebook.Types.Plain p0

        Evergreen.V97.Notebook.Types.Styled p0 ->
            Evergreen.V107.Notebook.Types.Styled (p0 |> migrate_Notebook_Types_StyledString)


migrate_Notebook_Types_StyledString : Evergreen.V97.Notebook.Types.StyledString -> Evergreen.V107.Notebook.Types.StyledString
migrate_Notebook_Types_StyledString old =
    old


migrate_Types_AppMode : Evergreen.V97.Types.AppMode -> Evergreen.V107.Types.AppMode
migrate_Types_AppMode old =
    case old of
        Evergreen.V97.Types.AMWorking ->
            Evergreen.V107.Types.AMWorking

        Evergreen.V97.Types.AMEditTitle ->
            Evergreen.V107.Types.AMEditTitle


migrate_Types_ClockState : Evergreen.V97.Types.ClockState -> Evergreen.V107.Types.ClockState
migrate_Types_ClockState old =
    case old of
        Evergreen.V97.Types.ClockRunning ->
            Evergreen.V107.Types.ClockRunning

        Evergreen.V97.Types.ClockStopped ->
            Evergreen.V107.Types.ClockStopped

        Evergreen.V97.Types.ClockPaused ->
            Evergreen.V107.Types.ClockPaused


migrate_Types_DataSetDescription : Evergreen.V97.Types.DataSetDescription -> Evergreen.V107.Types.DataSetDescription
migrate_Types_DataSetDescription old =
    case old of
        Evergreen.V97.Types.PublicDatasets ->
            Evergreen.V107.Types.PublicDatasets

        Evergreen.V97.Types.UserDatasets p0 ->
            Evergreen.V107.Types.UserDatasets p0


migrate_Types_FrontendMsg : Evergreen.V97.Types.FrontendMsg -> Evergreen.V107.Types.FrontendMsg
migrate_Types_FrontendMsg old =
    case old of
        Evergreen.V97.Types.UrlClicked p0 ->
            Evergreen.V107.Types.UrlClicked p0

        Evergreen.V97.Types.UrlChanged p0 ->
            Evergreen.V107.Types.UrlChanged p0

        Evergreen.V97.Types.NoOpFrontendMsg ->
            Evergreen.V107.Types.NoOpFrontendMsg

        Evergreen.V97.Types.FETick p0 ->
            Evergreen.V107.Types.FETick p0

        Evergreen.V97.Types.KeyboardMsg p0 ->
            Evergreen.V107.Types.KeyboardMsg p0

        Evergreen.V97.Types.GetRandomProbabilities p0 ->
            Evergreen.V107.Types.GetRandomProbabilities p0

        Evergreen.V97.Types.GotRandomProbabilities p0 ->
            Evergreen.V107.Types.GotRandomProbabilities p0

        Evergreen.V97.Types.StringDataRequested p0 p1 ->
            Evergreen.V107.Types.StringDataRequested p0 p1

        Evergreen.V97.Types.StringDataSelected p0 p1 p2 ->
            Evergreen.V107.Types.StringDataSelected p0 p1 p2

        Evergreen.V97.Types.StringDataLoaded p0 p1 p2 p3 ->
            Evergreen.V107.Types.StringDataLoaded p0 p1 p2 p3

        Evergreen.V97.Types.InputName p0 ->
            Evergreen.V107.Types.InputName p0

        Evergreen.V97.Types.InputIdentifier p0 ->
            Evergreen.V107.Types.InputIdentifier p0

        Evergreen.V97.Types.InputDescription p0 ->
            Evergreen.V107.Types.InputDescription p0

        Evergreen.V97.Types.InputComments p0 ->
            Evergreen.V107.Types.InputComments p0

        Evergreen.V97.Types.InputData p0 ->
            Evergreen.V107.Types.InputData p0

        Evergreen.V97.Types.InputCommand p0 ->
            Evergreen.V107.Types.InputCommand p0

        Evergreen.V97.Types.InputPackages p0 ->
            Evergreen.V107.Types.InputPackages p0

        Evergreen.V97.Types.InputAuthor p0 ->
            Evergreen.V107.Types.InputAuthor p0

        Evergreen.V97.Types.InputInitialStateValue p0 ->
            Evergreen.V107.Types.InputInitialStateValue p0

        Evergreen.V97.Types.SendProgramToBeCompiled ->
            Evergreen.V107.Types.SendProgramToBeCompiled

        Evergreen.V97.Types.GotCompiledProgram p0 ->
            Evergreen.V107.Types.GotCompiledProgram p0

        Evergreen.V97.Types.ToggleTheme p0 ->
            Evergreen.V107.Types.ToggleTheme (p0 |> migrate_Notebook_Book_Theme)

        Evergreen.V97.Types.ExecuteDelayedFunction ->
            Evergreen.V107.Types.ExecuteDelayedFunction

        Evergreen.V97.Types.ExecuteDelayedFunction2 ->
            Evergreen.V107.Types.ExecuteDelayedFunction2

        Evergreen.V97.Types.ExecuteDelayedMessageRemoval p0 ->
            Evergreen.V107.Types.ExecuteDelayedMessageRemoval p0

        Evergreen.V97.Types.GetPackagesFromCompiler ->
            Evergreen.V107.Types.GetPackagesFromCompiler

        Evergreen.V97.Types.GotPackagesFromCompiler p0 ->
            Evergreen.V107.Types.GotPackagesFromCompiler p0

        Evergreen.V97.Types.GotElmJsonDict p0 ->
            Evergreen.V107.Types.GotElmJsonDict p0

        Evergreen.V97.Types.GotReplyFromCompiler p0 p1 ->
            Evergreen.V107.Types.GotReplyFromCompiler (p0 |> migrate_Notebook_Cell_Cell) p1

        Evergreen.V97.Types.ReceivedFromJS p0 ->
            Evergreen.V107.Types.ReceivedFromJS p0

        Evergreen.V97.Types.ReceiveJSData p0 ->
            Evergreen.V107.Types.ReceiveJSData p0

        Evergreen.V97.Types.AskToListDataSets p0 ->
            Evergreen.V107.Types.AskToListDataSets (p0 |> migrate_Types_DataSetDescription)

        Evergreen.V97.Types.AskToSaveDataSet p0 ->
            Evergreen.V107.Types.AskToSaveDataSet (p0 |> migrate_Notebook_DataSet_DataSetMetaData)

        Evergreen.V97.Types.AskToCreateDataSet ->
            Evergreen.V107.Types.AskToCreateDataSet

        Evergreen.V97.Types.AskToDeleteDataSet p0 ->
            Evergreen.V107.Types.AskToDeleteDataSet (p0 |> migrate_Notebook_DataSet_DataSetMetaData)

        Evergreen.V97.Types.SubmitPackageList ->
            Evergreen.V107.Types.SubmitPackageList

        Evergreen.V97.Types.SubmitTest ->
            Evergreen.V107.Types.SubmitTest

        Evergreen.V97.Types.RunCommand ->
            Evergreen.V107.Types.RunCommand

        Evergreen.V97.Types.PackageListSent p0 ->
            Evergreen.V107.Types.PackageListSent p0

        Evergreen.V97.Types.ClearNotebookValues ->
            Evergreen.V107.Types.ClearNotebookValues

        Evergreen.V97.Types.ExecuteNotebook ->
            Evergreen.V107.Types.ExecuteNotebook

        Evergreen.V97.Types.UpdateDeclarationsDictionary ->
            Evergreen.V107.Types.UpdateDeclarationsDictionary

        Evergreen.V97.Types.ExecuteCell p0 ->
            Evergreen.V107.Types.ExecuteCell p0

        Evergreen.V97.Types.ExecuteCells p0 ->
            Evergreen.V107.Types.ExecuteCells p0

        Evergreen.V97.Types.UpdateErrorReports ->
            Evergreen.V107.Types.UpdateErrorReports

        Evergreen.V97.Types.FetchDependencies p0 ->
            Evergreen.V107.Types.FetchDependencies p0

        Evergreen.V97.Types.ToggleCellLock p0 ->
            Evergreen.V107.Types.ToggleCellLock (p0 |> migrate_Notebook_Cell_Cell)

        Evergreen.V97.Types.ChangeCellInsertionDirection p0 ->
            Evergreen.V107.Types.ChangeCellInsertionDirection (p0 |> migrate_Notebook_Types_CellDirection)

        Evergreen.V97.Types.NewCodeCell p0 p1 ->
            Evergreen.V107.Types.NewCodeCell (p0 |> migrate_Notebook_Cell_CellState) p1

        Evergreen.V97.Types.NewMarkdownCell p0 p1 ->
            Evergreen.V107.Types.NewMarkdownCell (p0 |> migrate_Notebook_Cell_CellState) p1

        Evergreen.V97.Types.ToggleShowErrorPanel ->
            Evergreen.V107.Types.ToggleShowErrorPanel

        Evergreen.V97.Types.DeleteCell p0 ->
            Evergreen.V107.Types.DeleteCell p0

        Evergreen.V97.Types.MoveCell p0 p1 ->
            Evergreen.V107.Types.MoveCell p0 (p1 |> migrate_Notebook_Book_DirectionToMove)

        Evergreen.V97.Types.EditCell p0 ->
            Evergreen.V107.Types.EditCell (p0 |> migrate_Notebook_Cell_Cell)

        Evergreen.V97.Types.ClearCell p0 ->
            Evergreen.V107.Types.ClearCell p0

        Evergreen.V97.Types.EvalCell p0 p1 ->
            Evergreen.V107.Types.EvalCell (p0 |> migrate_Notebook_Cell_CellState) p1

        Evergreen.V97.Types.InputElmCode p0 p1 ->
            Evergreen.V107.Types.InputElmCode p0 p1

        Evergreen.V97.Types.UpdateNotebookTitle ->
            Evergreen.V107.Types.UpdateNotebookTitle

        Evergreen.V97.Types.NewNotebook ->
            Evergreen.V107.Types.NewNotebook

        Evergreen.V97.Types.ProposeDeletingNotebook ->
            Evergreen.V107.Types.ProposeDeletingNotebook

        Evergreen.V97.Types.CancelDeleteNotebook ->
            Evergreen.V107.Types.CancelDeleteNotebook

        Evergreen.V97.Types.ChangeAppMode p0 ->
            Evergreen.V107.Types.ChangeAppMode (p0 |> migrate_Types_AppMode)

        Evergreen.V97.Types.SetClock p0 ->
            Evergreen.V107.Types.SetClock (p0 |> migrate_Types_ClockState)

        Evergreen.V97.Types.Reset ->
            Evergreen.V107.Types.Reset

        Evergreen.V97.Types.TogglePublic ->
            Evergreen.V107.Types.TogglePublic

        Evergreen.V97.Types.SetCurrentNotebook p0 ->
            Evergreen.V107.Types.SetCurrentNotebook (p0 |> migrate_Notebook_Book_Book)

        Evergreen.V97.Types.CloneNotebook ->
            Evergreen.V107.Types.CloneNotebook

        Evergreen.V97.Types.PullNotebook ->
            Evergreen.V107.Types.PullNotebook

        Evergreen.V97.Types.ExportNotebook ->
            Evergreen.V107.Types.ExportNotebook

        Evergreen.V97.Types.SetShowNotebooksState p0 ->
            Evergreen.V107.Types.SetShowNotebooksState (p0 |> migrate_Types_ShowNotebooks)

        Evergreen.V97.Types.ImportRequested ->
            Evergreen.V107.Types.ImportRequested

        Evergreen.V97.Types.ImportSelected p0 ->
            Evergreen.V107.Types.ImportSelected p0

        Evergreen.V97.Types.ImportLoaded p0 ->
            Evergreen.V107.Types.ImportLoaded p0

        Evergreen.V97.Types.ChangePopup p0 ->
            Evergreen.V107.Types.ChangePopup (p0 |> migrate_Types_PopupState)

        Evergreen.V97.Types.GotViewport p0 ->
            Evergreen.V107.Types.GotViewport p0

        Evergreen.V97.Types.GotNewWindowDimensions p0 p1 ->
            Evergreen.V107.Types.GotNewWindowDimensions p0 p1

        Evergreen.V97.Types.SignUp ->
            Evergreen.V107.Types.SignUp

        Evergreen.V97.Types.SignIn ->
            Evergreen.V107.Types.SignIn

        Evergreen.V97.Types.SignOut ->
            Evergreen.V107.Types.SignOut

        Evergreen.V97.Types.SetSignupState p0 ->
            Evergreen.V107.Types.SetSignupState (p0 |> migrate_Types_SignupState)

        Evergreen.V97.Types.InputUsername p0 ->
            Evergreen.V107.Types.InputUsername p0

        Evergreen.V97.Types.InputSignupUsername p0 ->
            Evergreen.V107.Types.InputSignupUsername p0

        Evergreen.V97.Types.InputPassword p0 ->
            Evergreen.V107.Types.InputPassword p0

        Evergreen.V97.Types.InputPasswordAgain p0 ->
            Evergreen.V107.Types.InputPasswordAgain p0

        Evergreen.V97.Types.InputEmail p0 ->
            Evergreen.V107.Types.InputEmail p0

        Evergreen.V97.Types.InputTitle p0 ->
            Evergreen.V107.Types.InputTitle p0

        Evergreen.V97.Types.InputCloneReference p0 ->
            Evergreen.V107.Types.InputCloneReference p0

        Evergreen.V97.Types.AdminRunTask ->
            Evergreen.V107.Types.AdminRunTask

        Evergreen.V97.Types.GetUsers ->
            Evergreen.V107.Types.GetUsers


migrate_Types_PopupState : Evergreen.V97.Types.PopupState -> Evergreen.V107.Types.PopupState
migrate_Types_PopupState old =
    case old of
        Evergreen.V97.Types.NoPopup ->
            Evergreen.V107.Types.NoPopup

        Evergreen.V97.Types.AdminPopup ->
            Evergreen.V107.Types.AdminPopup

        Evergreen.V97.Types.ManualPopup ->
            Evergreen.V107.Types.ManualPopup

        Evergreen.V97.Types.NewDataSetPopup ->
            Evergreen.V107.Types.NewDataSetPopup

        Evergreen.V97.Types.EditDataSetPopup p0 ->
            Evergreen.V107.Types.EditDataSetPopup (p0 |> migrate_Notebook_DataSet_DataSetMetaData)

        Evergreen.V97.Types.SignUpPopup ->
            Evergreen.V107.Types.SignUpPopup

        Evergreen.V97.Types.PackageListPopup ->
            Evergreen.V107.Types.PackageListPopup

        Evergreen.V97.Types.CLIPopup ->
            Evergreen.V107.Types.CLIPopup

        Evergreen.V97.Types.NewNotebookPopup ->
            Evergreen.V107.Types.NewNotebookPopup

        Evergreen.V97.Types.StateEditorPopup ->
            Evergreen.V107.Types.StateEditorPopup

        Evergreen.V97.Types.ViewPublicDataSetsPopup ->
            Evergreen.V107.Types.ViewPublicDataSetsPopup

        Evergreen.V97.Types.ViewPrivateDataSetsPopup ->
            Evergreen.V107.Types.ViewPrivateDataSetsPopup


migrate_Types_ShowNotebooks : Evergreen.V97.Types.ShowNotebooks -> Evergreen.V107.Types.ShowNotebooks
migrate_Types_ShowNotebooks old =
    case old of
        Evergreen.V97.Types.ShowUserNotebooks ->
            Evergreen.V107.Types.ShowUserNotebooks

        Evergreen.V97.Types.ShowPublicNotebooks ->
            Evergreen.V107.Types.ShowPublicNotebooks


migrate_Types_SignupState : Evergreen.V97.Types.SignupState -> Evergreen.V107.Types.SignupState
migrate_Types_SignupState old =
    case old of
        Evergreen.V97.Types.ShowSignUpForm ->
            Evergreen.V107.Types.ShowSignUpForm

        Evergreen.V97.Types.HideSignUpForm ->
            Evergreen.V107.Types.HideSignUpForm
