module Evergreen.Migrate.V2 exposing (..)

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

import Evergreen.V1.Notebook.Book
import Evergreen.V1.Notebook.Cell
import Evergreen.V1.Notebook.DataSet
import Evergreen.V1.Notebook.Types
import Evergreen.V1.Types
import Evergreen.V2.Notebook.Book
import Evergreen.V2.Notebook.Cell
import Evergreen.V2.Notebook.DataSet
import Evergreen.V2.Notebook.Types
import Evergreen.V2.Types
import Lamdera.Migrations exposing (..)
import List
import Maybe


frontendModel : Evergreen.V1.Types.FrontendModel -> ModelMigration Evergreen.V2.Types.FrontendModel Evergreen.V2.Types.FrontendMsg
frontendModel old =
    ModelUnchanged


backendModel : Evergreen.V1.Types.BackendModel -> ModelMigration Evergreen.V2.Types.BackendModel Evergreen.V2.Types.BackendMsg
backendModel old =
    ModelUnchanged


frontendMsg : Evergreen.V1.Types.FrontendMsg -> MsgMigration Evergreen.V2.Types.FrontendMsg Evergreen.V2.Types.FrontendMsg
frontendMsg old =
    MsgMigrated ( migrate_Types_FrontendMsg old, Cmd.none )


toBackend : Evergreen.V1.Types.ToBackend -> MsgMigration Evergreen.V2.Types.ToBackend Evergreen.V2.Types.BackendMsg
toBackend old =
    MsgUnchanged


backendMsg : Evergreen.V1.Types.BackendMsg -> MsgMigration Evergreen.V2.Types.BackendMsg Evergreen.V2.Types.BackendMsg
backendMsg old =
    MsgUnchanged


toFrontend : Evergreen.V1.Types.ToFrontend -> MsgMigration Evergreen.V2.Types.ToFrontend Evergreen.V2.Types.FrontendMsg
toFrontend old =
    MsgUnchanged


migrate_Notebook_Book_Book : Evergreen.V1.Notebook.Book.Book -> Evergreen.V2.Notebook.Book.Book
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
    }


migrate_Notebook_Cell_Cell : Evergreen.V1.Notebook.Cell.Cell -> Evergreen.V2.Notebook.Cell.Cell
migrate_Notebook_Cell_Cell old =
    { index = old.index
    , text = old.text
    , tipe = old.tipe |> migrate_Notebook_Cell_CellType
    , value = old.value |> migrate_Notebook_Cell_CellValue
    , cellState = old.cellState |> migrate_Notebook_Cell_CellState
    , locked = old.locked
    , report = old.report |> Maybe.map (List.map migrate_Notebook_Types_MessageItem)
    , replData = old.replData
    }


migrate_Notebook_Cell_CellState : Evergreen.V1.Notebook.Cell.CellState -> Evergreen.V2.Notebook.Cell.CellState
migrate_Notebook_Cell_CellState old =
    case old of
        Evergreen.V1.Notebook.Cell.CSEdit ->
            Evergreen.V2.Notebook.Cell.CSEdit

        Evergreen.V1.Notebook.Cell.CSView ->
            Evergreen.V2.Notebook.Cell.CSView


migrate_Notebook_Cell_CellType : Evergreen.V1.Notebook.Cell.CellType -> Evergreen.V2.Notebook.Cell.CellType
migrate_Notebook_Cell_CellType old =
    case old of
        Evergreen.V1.Notebook.Cell.CTCode ->
            Evergreen.V2.Notebook.Cell.CTCode

        Evergreen.V1.Notebook.Cell.CTMarkdown ->
            Evergreen.V2.Notebook.Cell.CTMarkdown


migrate_Notebook_Cell_CellValue : Evergreen.V1.Notebook.Cell.CellValue -> Evergreen.V2.Notebook.Cell.CellValue
migrate_Notebook_Cell_CellValue old =
    case old of
        Evergreen.V1.Notebook.Cell.CVString p0 ->
            Evergreen.V2.Notebook.Cell.CVString p0

        Evergreen.V1.Notebook.Cell.CVMarkdown p0 ->
            Evergreen.V2.Notebook.Cell.CVMarkdown p0

        Evergreen.V1.Notebook.Cell.CVNone ->
            Evergreen.V2.Notebook.Cell.CVNone


migrate_Notebook_DataSet_DataSetMetaData : Evergreen.V1.Notebook.DataSet.DataSetMetaData -> Evergreen.V2.Notebook.DataSet.DataSetMetaData
migrate_Notebook_DataSet_DataSetMetaData old =
    old


migrate_Notebook_Types_CellDirection : Evergreen.V1.Notebook.Types.CellDirection -> Evergreen.V2.Notebook.Types.CellDirection
migrate_Notebook_Types_CellDirection old =
    case old of
        Evergreen.V1.Notebook.Types.Up ->
            Evergreen.V2.Notebook.Types.Up

        Evergreen.V1.Notebook.Types.Down ->
            Evergreen.V2.Notebook.Types.Down


migrate_Notebook_Types_MessageItem : Evergreen.V1.Notebook.Types.MessageItem -> Evergreen.V2.Notebook.Types.MessageItem
migrate_Notebook_Types_MessageItem old =
    case old of
        Evergreen.V1.Notebook.Types.Plain p0 ->
            Evergreen.V2.Notebook.Types.Plain p0

        Evergreen.V1.Notebook.Types.Styled p0 ->
            Evergreen.V2.Notebook.Types.Styled (p0 |> migrate_Notebook_Types_StyledString)


migrate_Notebook_Types_StyledString : Evergreen.V1.Notebook.Types.StyledString -> Evergreen.V2.Notebook.Types.StyledString
migrate_Notebook_Types_StyledString old =
    old


migrate_Types_AppMode : Evergreen.V1.Types.AppMode -> Evergreen.V2.Types.AppMode
migrate_Types_AppMode old =
    case old of
        Evergreen.V1.Types.AMWorking ->
            Evergreen.V2.Types.AMWorking

        Evergreen.V1.Types.AMEditTitle ->
            Evergreen.V2.Types.AMEditTitle


migrate_Types_ClockState : Evergreen.V1.Types.ClockState -> Evergreen.V2.Types.ClockState
migrate_Types_ClockState old =
    case old of
        Evergreen.V1.Types.ClockRunning ->
            Evergreen.V2.Types.ClockRunning

        Evergreen.V1.Types.ClockStopped ->
            Evergreen.V2.Types.ClockStopped

        Evergreen.V1.Types.ClockPaused ->
            Evergreen.V2.Types.ClockPaused


migrate_Types_DataSetDescription : Evergreen.V1.Types.DataSetDescription -> Evergreen.V2.Types.DataSetDescription
migrate_Types_DataSetDescription old =
    case old of
        Evergreen.V1.Types.PublicDatasets ->
            Evergreen.V2.Types.PublicDatasets

        Evergreen.V1.Types.UserDatasets p0 ->
            Evergreen.V2.Types.UserDatasets p0


migrate_Types_FrontendMsg : Evergreen.V1.Types.FrontendMsg -> Evergreen.V2.Types.FrontendMsg
migrate_Types_FrontendMsg old =
    case old of
        Evergreen.V1.Types.UrlClicked p0 ->
            Evergreen.V2.Types.UrlClicked p0

        Evergreen.V1.Types.UrlChanged p0 ->
            Evergreen.V2.Types.UrlChanged p0

        Evergreen.V1.Types.NoOpFrontendMsg ->
            Evergreen.V2.Types.NoOpFrontendMsg

        Evergreen.V1.Types.FETick p0 ->
            Evergreen.V2.Types.FETick p0

        Evergreen.V1.Types.KeyboardMsg p0 ->
            Evergreen.V2.Types.KeyboardMsg p0

        Evergreen.V1.Types.GetRandomProbabilities p0 ->
            Evergreen.V2.Types.GetRandomProbabilities p0

        Evergreen.V1.Types.GotRandomProbabilities p0 ->
            Evergreen.V2.Types.GotRandomProbabilities p0

        Evergreen.V1.Types.StringDataRequested p0 p1 ->
            Evergreen.V2.Types.StringDataRequested p0 p1

        Evergreen.V1.Types.StringDataSelected p0 p1 p2 ->
            Evergreen.V2.Types.StringDataSelected p0 p1 p2

        Evergreen.V1.Types.StringDataLoaded p0 p1 p2 p3 ->
            Evergreen.V2.Types.StringDataLoaded p0 p1 p2 p3

        Evergreen.V1.Types.InputName p0 ->
            Evergreen.V2.Types.InputName p0

        Evergreen.V1.Types.InputIdentifier p0 ->
            Evergreen.V2.Types.InputIdentifier p0

        Evergreen.V1.Types.InputDescription p0 ->
            Evergreen.V2.Types.InputDescription p0

        Evergreen.V1.Types.InputComments p0 ->
            Evergreen.V2.Types.InputComments p0

        Evergreen.V1.Types.InputData p0 ->
            Evergreen.V2.Types.InputData p0

        Evergreen.V1.Types.InputPackages p0 ->
            Evergreen.V2.Types.InputPackages p0

        Evergreen.V1.Types.InputAuthor p0 ->
            Evergreen.V2.Types.InputAuthor p0

        Evergreen.V1.Types.InputInitialStateValue p0 ->
            Evergreen.V2.Types.InputInitialStateValue p0

        Evergreen.V1.Types.ExecuteDelayedFunction ->
            Evergreen.V2.Types.ExecuteDelayedFunction

        Evergreen.V1.Types.GotElmJsonDict p0 ->
            Evergreen.V2.Types.GotElmJsonDict p0

        Evergreen.V1.Types.GotReply p0 p1 ->
            Evergreen.V2.Types.GotReply (p0 |> migrate_Notebook_Cell_Cell) p1

        Evergreen.V1.Types.ReceivedFromJS p0 ->
            Evergreen.V2.Types.ReceivedFromJS p0

        Evergreen.V1.Types.AskToListDataSets p0 ->
            Evergreen.V2.Types.AskToListDataSets (p0 |> migrate_Types_DataSetDescription)

        Evergreen.V1.Types.AskToSaveDataSet p0 ->
            Evergreen.V2.Types.AskToSaveDataSet (p0 |> migrate_Notebook_DataSet_DataSetMetaData)

        Evergreen.V1.Types.AskToCreateDataSet ->
            Evergreen.V2.Types.AskToCreateDataSet

        Evergreen.V1.Types.AskToDeleteDataSet p0 ->
            Evergreen.V2.Types.AskToDeleteDataSet (p0 |> migrate_Notebook_DataSet_DataSetMetaData)

        Evergreen.V1.Types.SubmitPackageList ->
            Evergreen.V2.Types.SubmitPackageList

        Evergreen.V1.Types.SubmitTest ->
            Evergreen.V2.Types.SubmitTest

        Evergreen.V1.Types.PackageListSent p0 ->
            Evergreen.V2.Types.PackageListSent (p0 |> Result.map (\_ -> "()"))

        Evergreen.V1.Types.ClearNotebookValues ->
            Evergreen.V2.Types.ClearNotebookValues

        Evergreen.V1.Types.ExecuteNotebook ->
            Evergreen.V2.Types.ExecuteNotebook

        Evergreen.V1.Types.UpdateDeclarationsDictionary ->
            Evergreen.V2.Types.UpdateDeclarationsDictionary

        Evergreen.V1.Types.ExecuteCell p0 ->
            Evergreen.V2.Types.ExecuteCell p0

        Evergreen.V1.Types.FetchDependencies p0 ->
            Evergreen.V2.Types.FetchDependencies p0

        Evergreen.V1.Types.ToggleCellLock p0 ->
            Evergreen.V2.Types.ToggleCellLock (p0 |> migrate_Notebook_Cell_Cell)

        Evergreen.V1.Types.ChangeCellInsertionDirection p0 ->
            Evergreen.V2.Types.ChangeCellInsertionDirection (p0 |> migrate_Notebook_Types_CellDirection)

        Evergreen.V1.Types.NewCodeCell p0 p1 ->
            Evergreen.V2.Types.NewCodeCell (p0 |> migrate_Notebook_Cell_CellState) p1

        Evergreen.V1.Types.NewMarkdownCell p0 p1 ->
            Evergreen.V2.Types.NewMarkdownCell (p0 |> migrate_Notebook_Cell_CellState) p1

        Evergreen.V1.Types.DeleteCell p0 ->
            Evergreen.V2.Types.DeleteCell p0

        Evergreen.V1.Types.EditCell p0 ->
            Evergreen.V2.Types.EditCell (p0 |> migrate_Notebook_Cell_Cell)

        Evergreen.V1.Types.ClearCell p0 ->
            Evergreen.V2.Types.ClearCell p0

        Evergreen.V1.Types.EvalCell p0 p1 ->
            Evergreen.V2.Types.EvalCell (p0 |> migrate_Notebook_Cell_CellState) p1

        Evergreen.V1.Types.InputElmCode p0 p1 ->
            Evergreen.V2.Types.InputElmCode p0 p1

        Evergreen.V1.Types.UpdateNotebookTitle ->
            Evergreen.V2.Types.UpdateNotebookTitle

        Evergreen.V1.Types.NewNotebook ->
            Evergreen.V2.Types.NewNotebook

        Evergreen.V1.Types.ProposeDeletingNotebook ->
            Evergreen.V2.Types.ProposeDeletingNotebook

        Evergreen.V1.Types.CancelDeleteNotebook ->
            Evergreen.V2.Types.CancelDeleteNotebook

        Evergreen.V1.Types.ChangeAppMode p0 ->
            Evergreen.V2.Types.ChangeAppMode (p0 |> migrate_Types_AppMode)

        Evergreen.V1.Types.SetClock p0 ->
            Evergreen.V2.Types.SetClock (p0 |> migrate_Types_ClockState)

        Evergreen.V1.Types.Reset ->
            Evergreen.V2.Types.Reset

        Evergreen.V1.Types.TogglePublic ->
            Evergreen.V2.Types.TogglePublic

        Evergreen.V1.Types.SetCurrentNotebook p0 ->
            Evergreen.V2.Types.SetCurrentNotebook (p0 |> migrate_Notebook_Book_Book)

        Evergreen.V1.Types.CloneNotebook ->
            Evergreen.V2.Types.CloneNotebook

        Evergreen.V1.Types.PullNotebook ->
            Evergreen.V2.Types.PullNotebook

        Evergreen.V1.Types.ExportNotebook ->
            Evergreen.V2.Types.ExportNotebook

        Evergreen.V1.Types.SetShowNotebooksState p0 ->
            Evergreen.V2.Types.SetShowNotebooksState (p0 |> migrate_Types_ShowNotebooks)

        Evergreen.V1.Types.ImportRequested ->
            Evergreen.V2.Types.ImportRequested

        Evergreen.V1.Types.ImportSelected p0 ->
            Evergreen.V2.Types.ImportSelected p0

        Evergreen.V1.Types.ImportLoaded p0 ->
            Evergreen.V2.Types.ImportLoaded p0

        Evergreen.V1.Types.ChangePopup p0 ->
            Evergreen.V2.Types.ChangePopup (p0 |> migrate_Types_PopupState)

        Evergreen.V1.Types.GotViewport p0 ->
            Evergreen.V2.Types.GotViewport p0

        Evergreen.V1.Types.GotNewWindowDimensions p0 p1 ->
            Evergreen.V2.Types.GotNewWindowDimensions p0 p1

        Evergreen.V1.Types.SignUp ->
            Evergreen.V2.Types.SignUp

        Evergreen.V1.Types.SignIn ->
            Evergreen.V2.Types.SignIn

        Evergreen.V1.Types.SignOut ->
            Evergreen.V2.Types.SignOut

        Evergreen.V1.Types.SetSignupState p0 ->
            Evergreen.V2.Types.SetSignupState (p0 |> migrate_Types_SignupState)

        Evergreen.V1.Types.InputUsername p0 ->
            Evergreen.V2.Types.InputUsername p0

        Evergreen.V1.Types.InputSignupUsername p0 ->
            Evergreen.V2.Types.InputSignupUsername p0

        Evergreen.V1.Types.InputPassword p0 ->
            Evergreen.V2.Types.InputPassword p0

        Evergreen.V1.Types.InputPasswordAgain p0 ->
            Evergreen.V2.Types.InputPasswordAgain p0

        Evergreen.V1.Types.InputEmail p0 ->
            Evergreen.V2.Types.InputEmail p0

        Evergreen.V1.Types.InputTitle p0 ->
            Evergreen.V2.Types.InputTitle p0

        Evergreen.V1.Types.InputCloneReference p0 ->
            Evergreen.V2.Types.InputCloneReference p0

        Evergreen.V1.Types.AdminRunTask ->
            Evergreen.V2.Types.AdminRunTask

        Evergreen.V1.Types.GetUsers ->
            Evergreen.V2.Types.GetUsers


migrate_Types_PopupState : Evergreen.V1.Types.PopupState -> Evergreen.V2.Types.PopupState
migrate_Types_PopupState old =
    case old of
        Evergreen.V1.Types.NoPopup ->
            Evergreen.V2.Types.NoPopup

        Evergreen.V1.Types.AdminPopup ->
            Evergreen.V2.Types.AdminPopup

        Evergreen.V1.Types.ManualPopup ->
            Evergreen.V2.Types.ManualPopup

        Evergreen.V1.Types.NewDataSetPopup ->
            Evergreen.V2.Types.NewDataSetPopup

        Evergreen.V1.Types.EditDataSetPopup p0 ->
            Evergreen.V2.Types.EditDataSetPopup (p0 |> migrate_Notebook_DataSet_DataSetMetaData)

        Evergreen.V1.Types.SignUpPopup ->
            Evergreen.V2.Types.SignUpPopup

        Evergreen.V1.Types.PackageListPopup ->
            Evergreen.V2.Types.PackageListPopup

        Evergreen.V1.Types.NewNotebookPopup ->
            Evergreen.V2.Types.NewNotebookPopup

        Evergreen.V1.Types.StateEditorPopup ->
            Evergreen.V2.Types.StateEditorPopup

        Evergreen.V1.Types.ViewPublicDataSetsPopup ->
            Evergreen.V2.Types.ViewPublicDataSetsPopup

        Evergreen.V1.Types.ViewPrivateDataSetsPopup ->
            Evergreen.V2.Types.ViewPrivateDataSetsPopup


migrate_Types_ShowNotebooks : Evergreen.V1.Types.ShowNotebooks -> Evergreen.V2.Types.ShowNotebooks
migrate_Types_ShowNotebooks old =
    case old of
        Evergreen.V1.Types.ShowUserNotebooks ->
            Evergreen.V2.Types.ShowUserNotebooks

        Evergreen.V1.Types.ShowPublicNotebooks ->
            Evergreen.V2.Types.ShowPublicNotebooks


migrate_Types_SignupState : Evergreen.V1.Types.SignupState -> Evergreen.V2.Types.SignupState
migrate_Types_SignupState old =
    case old of
        Evergreen.V1.Types.ShowSignUpForm ->
            Evergreen.V2.Types.ShowSignUpForm

        Evergreen.V1.Types.HideSignUpForm ->
            Evergreen.V2.Types.HideSignUpForm