module Evergreen.Migrate.V64 exposing (..)

{-| This migration file was automatically generated by the lamdera compiler.

It includes:

  - A migration for each of the 6 Lamdera core types that has changed
  - A function named `migrate_ModuleName_TypeName` for each changed/custom type

Expect to see:

  - `Unimplementеd` values as placeholders wherever I was unable to figure out a clear migration path for you
  - `@NOTICE` comments for things you should know about, i.e. new custom type constructors that won't get any
    value mappings from the old type by default

You can edit this file however you wish! It won't be generated again.

See <https://dashboard.lamdera.com/docs/evergreen> for more info.

-}

import Evergreen.V63.LiveBook.DataSet
import Evergreen.V63.LiveBook.Types
import Evergreen.V63.Types
import Evergreen.V64.LiveBook.DataSet
import Evergreen.V64.LiveBook.Types
import Evergreen.V64.Types
import Lamdera.Migrations exposing (..)
import List


frontendModel : Evergreen.V63.Types.FrontendModel -> ModelMigration Evergreen.V64.Types.FrontendModel Evergreen.V64.Types.FrontendMsg
frontendModel old =
    ModelMigrated ( migrate_Types_FrontendModel old, Cmd.none )


backendModel : Evergreen.V63.Types.BackendModel -> ModelMigration Evergreen.V64.Types.BackendModel Evergreen.V64.Types.BackendMsg
backendModel old =
    ModelUnchanged


frontendMsg : Evergreen.V63.Types.FrontendMsg -> MsgMigration Evergreen.V64.Types.FrontendMsg Evergreen.V64.Types.FrontendMsg
frontendMsg old =
    MsgMigrated ( migrate_Types_FrontendMsg old, Cmd.none )


toBackend : Evergreen.V63.Types.ToBackend -> MsgMigration Evergreen.V64.Types.ToBackend Evergreen.V64.Types.BackendMsg
toBackend old =
    MsgUnchanged


backendMsg : Evergreen.V63.Types.BackendMsg -> MsgMigration Evergreen.V64.Types.BackendMsg Evergreen.V64.Types.BackendMsg
backendMsg old =
    MsgUnchanged


toFrontend : Evergreen.V63.Types.ToFrontend -> MsgMigration Evergreen.V64.Types.ToFrontend Evergreen.V64.Types.FrontendMsg
toFrontend old =
    MsgUnchanged


migrate_Types_FrontendModel : Evergreen.V63.Types.FrontendModel -> Evergreen.V64.Types.FrontendModel
migrate_Types_FrontendModel old =
    { key = old.key
    , url = old.url
    , message = old.message
    , messages = old.messages |> List.map migrate_Types_Message
    , appState = old.appState |> migrate_Types_AppState
    , appMode = old.appMode |> migrate_Types_AppMode
    , currentTime = old.currentTime
    , tickCount = 0
    , pressedKeys = old.pressedKeys
    , users = old.users
    , inputName = old.inputName
    , inputIdentifier = old.inputIdentifier
    , inputAuthor = old.inputAuthor
    , inputDescription = old.inputDescription
    , inputComments = old.inputComments
    , inputData = old.inputData
    , publicDataSetMetaDataList = old.publicDataSetMetaDataList
    , privateDataSetMetaDataList = old.privateDataSetMetaDataList
    , kvDict = old.kvDict
    , books = old.books |> List.map migrate_LiveBook_Types_Book
    , currentBook = old.currentBook |> migrate_LiveBook_Types_Book
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


migrate_LiveBook_DataSet_DataSetMetaData : Evergreen.V63.LiveBook.DataSet.DataSetMetaData -> Evergreen.V64.LiveBook.DataSet.DataSetMetaData
migrate_LiveBook_DataSet_DataSetMetaData old =
    old


migrate_LiveBook_Types_Book : Evergreen.V63.LiveBook.Types.Book -> Evergreen.V64.LiveBook.Types.Book
migrate_LiveBook_Types_Book old =
    { id = old.id
    , dirty = old.dirty
    , slug = old.slug
    , origin = old.origin
    , author = old.author
    , createdAt = old.createdAt
    , updatedAt = old.updatedAt
    , public = old.public
    , title = old.title
    , cells = old.cells |> List.map migrate_LiveBook_Types_Cell
    , currentIndex = old.currentIndex
    }


migrate_LiveBook_Types_Cell : Evergreen.V63.LiveBook.Types.Cell -> Evergreen.V64.LiveBook.Types.Cell
migrate_LiveBook_Types_Cell old =
    { index = old.index
    , text = old.text
    , bindings = old.bindings
    , expression = old.expression
    , value = old.value |> migrate_LiveBook_Types_CellValue
    , cellState = old.cellState |> migrate_LiveBook_Types_CellState
    , locked = old.locked
    }


migrate_LiveBook_Types_CellState : Evergreen.V63.LiveBook.Types.CellState -> Evergreen.V64.LiveBook.Types.CellState
migrate_LiveBook_Types_CellState old =
    case old of
        Evergreen.V63.LiveBook.Types.CSEdit ->
            Evergreen.V64.LiveBook.Types.CSEdit

        Evergreen.V63.LiveBook.Types.CSView ->
            Evergreen.V64.LiveBook.Types.CSView


migrate_LiveBook_Types_CellValue : Evergreen.V63.LiveBook.Types.CellValue -> Evergreen.V64.LiveBook.Types.CellValue
migrate_LiveBook_Types_CellValue old =
    case old of
        Evergreen.V63.LiveBook.Types.CVNone ->
            Evergreen.V64.LiveBook.Types.CVNone

        Evergreen.V63.LiveBook.Types.CVString p0 ->
            Evergreen.V64.LiveBook.Types.CVString p0

        Evergreen.V63.LiveBook.Types.CVVisual p0 p1 ->
            Evergreen.V64.LiveBook.Types.CVVisual (p0 |> migrate_LiveBook_Types_VisualType) p1


migrate_LiveBook_Types_VisualType : Evergreen.V63.LiveBook.Types.VisualType -> Evergreen.V64.LiveBook.Types.VisualType
migrate_LiveBook_Types_VisualType old =
    case old of
        Evergreen.V63.LiveBook.Types.VTChart ->
            Evergreen.V64.LiveBook.Types.VTChart

        Evergreen.V63.LiveBook.Types.VTPlot2D ->
            Evergreen.V64.LiveBook.Types.VTPlot2D

        Evergreen.V63.LiveBook.Types.VTSvg ->
            Evergreen.V64.LiveBook.Types.VTSvg

        Evergreen.V63.LiveBook.Types.VTImage ->
            Evergreen.V64.LiveBook.Types.VTImage


migrate_Types_AppMode : Evergreen.V63.Types.AppMode -> Evergreen.V64.Types.AppMode
migrate_Types_AppMode old =
    case old of
        Evergreen.V63.Types.AMWorking ->
            Evergreen.V64.Types.AMWorking

        Evergreen.V63.Types.AMEditTitle ->
            Evergreen.V64.Types.AMEditTitle


migrate_Types_AppState : Evergreen.V63.Types.AppState -> Evergreen.V64.Types.AppState
migrate_Types_AppState old =
    case old of
        Evergreen.V63.Types.Loading ->
            Evergreen.V64.Types.Loading

        Evergreen.V63.Types.Loaded ->
            Evergreen.V64.Types.Loaded


migrate_Types_DataSetDescription : Evergreen.V63.Types.DataSetDescription -> Evergreen.V64.Types.DataSetDescription
migrate_Types_DataSetDescription old =
    case old of
        Evergreen.V63.Types.PublicDatasets ->
            Evergreen.V64.Types.PublicDatasets

        Evergreen.V63.Types.UserDatasets p0 ->
            Evergreen.V64.Types.UserDatasets p0


migrate_Types_DeleteNotebookState : Evergreen.V63.Types.DeleteNotebookState -> Evergreen.V64.Types.DeleteNotebookState
migrate_Types_DeleteNotebookState old =
    case old of
        Evergreen.V63.Types.WaitingToDeleteNotebook ->
            Evergreen.V64.Types.WaitingToDeleteNotebook

        Evergreen.V63.Types.CanDeleteNotebook ->
            Evergreen.V64.Types.CanDeleteNotebook


migrate_Types_FrontendMsg : Evergreen.V63.Types.FrontendMsg -> Evergreen.V64.Types.FrontendMsg
migrate_Types_FrontendMsg old =
    case old of
        Evergreen.V63.Types.UrlClicked p0 ->
            Evergreen.V64.Types.UrlClicked p0

        Evergreen.V63.Types.UrlChanged p0 ->
            Evergreen.V64.Types.UrlChanged p0

        Evergreen.V63.Types.NoOpFrontendMsg ->
            Evergreen.V64.Types.NoOpFrontendMsg

        Evergreen.V63.Types.FETick p0 ->
            Evergreen.V64.Types.FETick p0

        Evergreen.V63.Types.KeyboardMsg p0 ->
            Evergreen.V64.Types.KeyboardMsg p0

        Evergreen.V63.Types.StringDataRequested p0 p1 ->
            Evergreen.V64.Types.StringDataRequested p0 p1

        Evergreen.V63.Types.StringDataSelected p0 p1 p2 ->
            Evergreen.V64.Types.StringDataSelected p0 p1 p2

        Evergreen.V63.Types.StringDataLoaded p0 p1 p2 p3 ->
            Evergreen.V64.Types.StringDataLoaded p0 p1 p2 p3

        Evergreen.V63.Types.InputName p0 ->
            Evergreen.V64.Types.InputName p0

        Evergreen.V63.Types.InputIdentifier p0 ->
            Evergreen.V64.Types.InputIdentifier p0

        Evergreen.V63.Types.InputDescription p0 ->
            Evergreen.V64.Types.InputDescription p0

        Evergreen.V63.Types.InputComments p0 ->
            Evergreen.V64.Types.InputComments p0

        Evergreen.V63.Types.InputData p0 ->
            Evergreen.V64.Types.InputData p0

        Evergreen.V63.Types.InputAuthor p0 ->
            Evergreen.V64.Types.InputAuthor p0

        Evergreen.V63.Types.AskToListDataSets p0 ->
            Evergreen.V64.Types.AskToListDataSets (p0 |> migrate_Types_DataSetDescription)

        Evergreen.V63.Types.AskToSaveDataSet p0 ->
            Evergreen.V64.Types.AskToSaveDataSet (p0 |> migrate_LiveBook_DataSet_DataSetMetaData)

        Evergreen.V63.Types.AskToCreateDataSet ->
            Evergreen.V64.Types.AskToCreateDataSet

        Evergreen.V63.Types.AskToDeleteDataSet p0 ->
            Evergreen.V64.Types.AskToDeleteDataSet (p0 |> migrate_LiveBook_DataSet_DataSetMetaData)

        Evergreen.V63.Types.ToggleCellLock p0 ->
            Evergreen.V64.Types.ToggleCellLock (p0 |> migrate_LiveBook_Types_Cell)

        Evergreen.V63.Types.NewCell p0 ->
            Evergreen.V64.Types.NewCell p0

        Evergreen.V63.Types.DeleteCell p0 ->
            Evergreen.V64.Types.DeleteCell p0

        Evergreen.V63.Types.EditCell p0 ->
            Evergreen.V64.Types.EditCell p0

        Evergreen.V63.Types.ClearCell p0 ->
            Evergreen.V64.Types.ClearCell p0

        Evergreen.V63.Types.EvalCell p0 ->
            Evergreen.V64.Types.EvalCell p0

        Evergreen.V63.Types.InputElmCode p0 p1 ->
            Evergreen.V64.Types.InputElmCode p0 p1

        Evergreen.V63.Types.UpdateNotebookTitle ->
            Evergreen.V64.Types.UpdateNotebookTitle

        Evergreen.V63.Types.NewNotebook ->
            Evergreen.V64.Types.NewNotebook

        Evergreen.V63.Types.ProposeDeletingNotebook ->
            Evergreen.V64.Types.ProposeDeletingNotebook

        Evergreen.V63.Types.CancelDeleteNotebook ->
            Evergreen.V64.Types.CancelDeleteNotebook

        Evergreen.V63.Types.ChangeAppMode p0 ->
            Evergreen.V64.Types.ChangeAppMode (p0 |> migrate_Types_AppMode)

        Evergreen.V63.Types.TogglePublic ->
            Evergreen.V64.Types.TogglePublic

        Evergreen.V63.Types.ClearNotebookValues ->
            Evergreen.V64.Types.ClearNotebookValues

        Evergreen.V63.Types.SetCurrentNotebook p0 ->
            Evergreen.V64.Types.SetCurrentNotebook (p0 |> migrate_LiveBook_Types_Book)

        Evergreen.V63.Types.CloneNotebook ->
            Evergreen.V64.Types.CloneNotebook

        Evergreen.V63.Types.PullNotebook ->
            Evergreen.V64.Types.PullNotebook

        Evergreen.V63.Types.SetShowNotebooksState p0 ->
            Evergreen.V64.Types.SetShowNotebooksState (p0 |> migrate_Types_ShowNotebooks)

        Evergreen.V63.Types.ChangePopup p0 ->
            Evergreen.V64.Types.ChangePopup (p0 |> migrate_Types_PopupState)

        Evergreen.V63.Types.GotViewport p0 ->
            Evergreen.V64.Types.GotViewport p0

        Evergreen.V63.Types.GotNewWindowDimensions p0 p1 ->
            Evergreen.V64.Types.GotNewWindowDimensions p0 p1

        Evergreen.V63.Types.SignUp ->
            Evergreen.V64.Types.SignUp

        Evergreen.V63.Types.SignIn ->
            Evergreen.V64.Types.SignIn

        Evergreen.V63.Types.SignOut ->
            Evergreen.V64.Types.SignOut

        Evergreen.V63.Types.SetSignupState p0 ->
            Evergreen.V64.Types.SetSignupState (p0 |> migrate_Types_SignupState)

        Evergreen.V63.Types.InputUsername p0 ->
            Evergreen.V64.Types.InputUsername p0

        Evergreen.V63.Types.InputSignupUsername p0 ->
            Evergreen.V64.Types.InputSignupUsername p0

        Evergreen.V63.Types.InputPassword p0 ->
            Evergreen.V64.Types.InputPassword p0

        Evergreen.V63.Types.InputPasswordAgain p0 ->
            Evergreen.V64.Types.InputPasswordAgain p0

        Evergreen.V63.Types.InputEmail p0 ->
            Evergreen.V64.Types.InputEmail p0

        Evergreen.V63.Types.InputTitle p0 ->
            Evergreen.V64.Types.InputTitle p0

        Evergreen.V63.Types.InputCloneReference p0 ->
            Evergreen.V64.Types.InputCloneReference p0

        Evergreen.V63.Types.AdminRunTask ->
            Evergreen.V64.Types.AdminRunTask

        Evergreen.V63.Types.GetUsers ->
            Evergreen.V64.Types.GetUsers


migrate_Types_Message : Evergreen.V63.Types.Message -> Evergreen.V64.Types.Message
migrate_Types_Message old =
    { txt = old.txt
    , status = old.status |> migrate_Types_MessageStatus
    }


migrate_Types_MessageStatus : Evergreen.V63.Types.MessageStatus -> Evergreen.V64.Types.MessageStatus
migrate_Types_MessageStatus old =
    case old of
        Evergreen.V63.Types.MSWhite ->
            Evergreen.V64.Types.MSWhite

        Evergreen.V63.Types.MSYellow ->
            Evergreen.V64.Types.MSYellow

        Evergreen.V63.Types.MSGreen ->
            Evergreen.V64.Types.MSGreen

        Evergreen.V63.Types.MSRed ->
            Evergreen.V64.Types.MSRed


migrate_Types_PopupState : Evergreen.V63.Types.PopupState -> Evergreen.V64.Types.PopupState
migrate_Types_PopupState old =
    case old of
        Evergreen.V63.Types.NoPopup ->
            Evergreen.V64.Types.NoPopup

        Evergreen.V63.Types.AdminPopup ->
            Evergreen.V64.Types.AdminPopup

        Evergreen.V63.Types.ManualPopup ->
            Evergreen.V64.Types.ManualPopup

        Evergreen.V63.Types.NewDataSetPopup ->
            Evergreen.V64.Types.NewDataSetPopup

        Evergreen.V63.Types.EditDataSetPopup p0 ->
            Evergreen.V64.Types.EditDataSetPopup (p0 |> migrate_LiveBook_DataSet_DataSetMetaData)

        Evergreen.V63.Types.SignUpPopup ->
            Evergreen.V64.Types.SignUpPopup

        Evergreen.V63.Types.NewNotebookPopup ->
            Evergreen.V64.Types.NewNotebookPopup

        Evergreen.V63.Types.ViewPublicDataSetsPopup ->
            Evergreen.V64.Types.ViewPublicDataSetsPopup

        Evergreen.V63.Types.ViewPrivateDataSetsPopup ->
            Evergreen.V64.Types.ViewPrivateDataSetsPopup


migrate_Types_ShowNotebooks : Evergreen.V63.Types.ShowNotebooks -> Evergreen.V64.Types.ShowNotebooks
migrate_Types_ShowNotebooks old =
    case old of
        Evergreen.V63.Types.ShowUserNotebooks ->
            Evergreen.V64.Types.ShowUserNotebooks

        Evergreen.V63.Types.ShowPublicNotebooks ->
            Evergreen.V64.Types.ShowPublicNotebooks


migrate_Types_SignupState : Evergreen.V63.Types.SignupState -> Evergreen.V64.Types.SignupState
migrate_Types_SignupState old =
    case old of
        Evergreen.V63.Types.ShowSignUpForm ->
            Evergreen.V64.Types.ShowSignUpForm

        Evergreen.V63.Types.HideSignUpForm ->
            Evergreen.V64.Types.HideSignUpForm