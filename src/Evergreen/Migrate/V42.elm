module Evergreen.Migrate.V42 exposing (..)

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

import Evergreen.V40.Types
import Evergreen.V42.Types
import Lamdera.Migrations exposing (..)
import List


frontendModel : Evergreen.V40.Types.FrontendModel -> ModelMigration Evergreen.V42.Types.FrontendModel Evergreen.V42.Types.FrontendMsg
frontendModel old =
    ModelUnchanged


backendModel : Evergreen.V40.Types.BackendModel -> ModelMigration Evergreen.V42.Types.BackendModel Evergreen.V42.Types.BackendMsg
backendModel old =
    ModelUnchanged


frontendMsg : Evergreen.V40.Types.FrontendMsg -> MsgMigration Evergreen.V42.Types.FrontendMsg Evergreen.V42.Types.FrontendMsg
frontendMsg old =
    MsgMigrated ( migrate_Types_FrontendMsg old, Cmd.none )


toBackend : Evergreen.V40.Types.ToBackend -> MsgMigration Evergreen.V42.Types.ToBackend Evergreen.V42.Types.BackendMsg
toBackend old =
    MsgUnchanged


backendMsg : Evergreen.V40.Types.BackendMsg -> MsgMigration Evergreen.V42.Types.BackendMsg Evergreen.V42.Types.BackendMsg
backendMsg old =
    MsgUnchanged


toFrontend : Evergreen.V40.Types.ToFrontend -> MsgMigration Evergreen.V42.Types.ToFrontend Evergreen.V42.Types.FrontendMsg
toFrontend old =
    MsgUnchanged


migrate_Types_AppMode : Evergreen.V40.Types.AppMode -> Evergreen.V42.Types.AppMode
migrate_Types_AppMode old =
    case old of
        Evergreen.V40.Types.AMWorking ->
            Evergreen.V42.Types.AMWorking

        Evergreen.V40.Types.AMEditTitle ->
            Evergreen.V42.Types.AMEditTitle


migrate_Types_Book : Evergreen.V40.Types.Book -> Evergreen.V42.Types.Book
migrate_Types_Book old =
    { id = old.id
    , dirty = old.dirty
    , slug = old.slug
    , origin = old.origin
    , author = old.author
    , createdAt = old.createdAt
    , updatedAt = old.updatedAt
    , public = old.public
    , title = old.title
    , cells = old.cells |> List.map migrate_Types_Cell
    , currentIndex = old.currentIndex
    }


migrate_Types_Cell : Evergreen.V40.Types.Cell -> Evergreen.V42.Types.Cell
migrate_Types_Cell old =
    { index = old.index
    , text = old.text
    , value = old.value
    , cellState = old.cellState |> migrate_Types_CellState
    }


migrate_Types_CellState : Evergreen.V40.Types.CellState -> Evergreen.V42.Types.CellState
migrate_Types_CellState old =
    case old of
        Evergreen.V40.Types.CSEdit ->
            Evergreen.V42.Types.CSEdit

        Evergreen.V40.Types.CSView ->
            Evergreen.V42.Types.CSView


migrate_Types_FrontendMsg : Evergreen.V40.Types.FrontendMsg -> Evergreen.V42.Types.FrontendMsg
migrate_Types_FrontendMsg old =
    case old of
        Evergreen.V40.Types.UrlClicked p0 ->
            Evergreen.V42.Types.UrlClicked p0

        Evergreen.V40.Types.UrlChanged p0 ->
            Evergreen.V42.Types.UrlChanged p0

        Evergreen.V40.Types.NoOpFrontendMsg ->
            Evergreen.V42.Types.NoOpFrontendMsg

        Evergreen.V40.Types.FETick p0 ->
            Evergreen.V42.Types.FETick p0

        Evergreen.V40.Types.KeyboardMsg p0 ->
            Evergreen.V42.Types.KeyboardMsg p0

        Evergreen.V40.Types.NewCell p0 ->
            Evergreen.V42.Types.NewCell p0

        Evergreen.V40.Types.EditCell p0 ->
            Evergreen.V42.Types.EditCell p0

        Evergreen.V40.Types.ClearCell p0 ->
            Evergreen.V42.Types.ClearCell p0

        Evergreen.V40.Types.EvalCell p0 ->
            Evergreen.V42.Types.EvalCell p0

        Evergreen.V40.Types.InputElmCode p0 p1 ->
            Evergreen.V42.Types.InputElmCode p0 p1

        Evergreen.V40.Types.UpdateNotebookTitle ->
            Evergreen.V42.Types.UpdateNotebookTitle

        Evergreen.V40.Types.NewNotebook ->
            Evergreen.V42.Types.NewNotebook

        Evergreen.V40.Types.ProposeDeletingNotebook ->
            Evergreen.V42.Types.ProposeDeletingNotebook

        Evergreen.V40.Types.CancelDeleteNotebook ->
            Evergreen.V42.Types.CancelDeleteNotebook

        Evergreen.V40.Types.ChangeAppMode p0 ->
            Evergreen.V42.Types.ChangeAppMode (p0 |> migrate_Types_AppMode)

        Evergreen.V40.Types.TogglePublic ->
            Evergreen.V42.Types.TogglePublic

        Evergreen.V40.Types.SetCurrentNotebook p0 ->
            Evergreen.V42.Types.SetCurrentNotebook (p0 |> migrate_Types_Book)

        Evergreen.V40.Types.CloneNotebook ->
            Evergreen.V42.Types.CloneNotebook

        Evergreen.V40.Types.PullNotebook ->
            Evergreen.V42.Types.PullNotebook

        Evergreen.V40.Types.SetShowNotebooksState p0 ->
            Evergreen.V42.Types.SetShowNotebooksState (p0 |> migrate_Types_ShowNotebooks)

        Evergreen.V40.Types.ChangePopup p0 ->
            Evergreen.V42.Types.ChangePopup (p0 |> migrate_Types_PopupState)

        Evergreen.V40.Types.GotViewport p0 ->
            Evergreen.V42.Types.GotViewport p0

        Evergreen.V40.Types.GotNewWindowDimensions p0 p1 ->
            Evergreen.V42.Types.GotNewWindowDimensions p0 p1

        Evergreen.V40.Types.SignUp ->
            Evergreen.V42.Types.SignUp

        Evergreen.V40.Types.SignIn ->
            Evergreen.V42.Types.SignIn

        Evergreen.V40.Types.SignOut ->
            Evergreen.V42.Types.SignOut

        Evergreen.V40.Types.SetSignupState p0 ->
            Evergreen.V42.Types.SetSignupState (p0 |> migrate_Types_SignupState)

        Evergreen.V40.Types.InputUsername p0 ->
            Evergreen.V42.Types.InputUsername p0

        Evergreen.V40.Types.InputSignupUsername p0 ->
            Evergreen.V42.Types.InputSignupUsername p0

        Evergreen.V40.Types.InputPassword p0 ->
            Evergreen.V42.Types.InputPassword p0

        Evergreen.V40.Types.InputPasswordAgain p0 ->
            Evergreen.V42.Types.InputPasswordAgain p0

        Evergreen.V40.Types.InputEmail p0 ->
            Evergreen.V42.Types.InputEmail p0

        Evergreen.V40.Types.InputTitle p0 ->
            Evergreen.V42.Types.InputTitle p0

        Evergreen.V40.Types.InputCloneReference p0 ->
            Evergreen.V42.Types.InputCloneReference p0

        Evergreen.V40.Types.AdminRunTask ->
            Evergreen.V42.Types.AdminRunTask

        Evergreen.V40.Types.GetUsers ->
            Evergreen.V42.Types.GetUsers


migrate_Types_PopupState : Evergreen.V40.Types.PopupState -> Evergreen.V42.Types.PopupState
migrate_Types_PopupState old =
    case old of
        Evergreen.V40.Types.NoPopup ->
            Evergreen.V42.Types.NoPopup

        Evergreen.V40.Types.AdminPopup ->
            Evergreen.V42.Types.AdminPopup

        Evergreen.V40.Types.ManualPopup ->
            Evergreen.V42.Types.ManualPopup

        Evergreen.V40.Types.SignUpPopup ->
            Evergreen.V42.Types.SignUpPopup

        Evergreen.V40.Types.NewNotebookPopup ->
            Evergreen.V42.Types.NewNotebookPopup


migrate_Types_ShowNotebooks : Evergreen.V40.Types.ShowNotebooks -> Evergreen.V42.Types.ShowNotebooks
migrate_Types_ShowNotebooks old =
    case old of
        Evergreen.V40.Types.ShowUserNotebooks ->
            Evergreen.V42.Types.ShowUserNotebooks

        Evergreen.V40.Types.ShowPublicNotebooks ->
            Evergreen.V42.Types.ShowPublicNotebooks


migrate_Types_SignupState : Evergreen.V40.Types.SignupState -> Evergreen.V42.Types.SignupState
migrate_Types_SignupState old =
    case old of
        Evergreen.V40.Types.ShowSignUpForm ->
            Evergreen.V42.Types.ShowSignUpForm

        Evergreen.V40.Types.HideSignUpForm ->
            Evergreen.V42.Types.HideSignUpForm
