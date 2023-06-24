module Evergreen.Migrate.V40 exposing (..)

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

import Evergreen.V37.Types
import Evergreen.V37.User
import Evergreen.V40.Types
import Evergreen.V40.User
import Lamdera.Migrations exposing (..)
import List


frontendModel : Evergreen.V37.Types.FrontendModel -> ModelMigration Evergreen.V40.Types.FrontendModel Evergreen.V40.Types.FrontendMsg
frontendModel old =
    ModelUnchanged


backendModel : Evergreen.V37.Types.BackendModel -> ModelMigration Evergreen.V40.Types.BackendModel Evergreen.V40.Types.BackendMsg
backendModel old =
    ModelUnchanged


frontendMsg : Evergreen.V37.Types.FrontendMsg -> MsgMigration Evergreen.V40.Types.FrontendMsg Evergreen.V40.Types.FrontendMsg
frontendMsg old =
    MsgUnchanged


toBackend : Evergreen.V37.Types.ToBackend -> MsgMigration Evergreen.V40.Types.ToBackend Evergreen.V40.Types.BackendMsg
toBackend old =
    MsgMigrated ( migrate_Types_ToBackend old, Cmd.none )


backendMsg : Evergreen.V37.Types.BackendMsg -> MsgMigration Evergreen.V40.Types.BackendMsg Evergreen.V40.Types.BackendMsg
backendMsg old =
    MsgUnchanged


toFrontend : Evergreen.V37.Types.ToFrontend -> MsgMigration Evergreen.V40.Types.ToFrontend Evergreen.V40.Types.FrontendMsg
toFrontend old =
    MsgUnchanged


migrate_Types_Book : Evergreen.V37.Types.Book -> Evergreen.V40.Types.Book
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


migrate_Types_Cell : Evergreen.V37.Types.Cell -> Evergreen.V40.Types.Cell
migrate_Types_Cell old =
    { index = old.index
    , text = old.text
    , value = old.value
    , cellState = old.cellState |> migrate_Types_CellState
    }


migrate_Types_CellState : Evergreen.V37.Types.CellState -> Evergreen.V40.Types.CellState
migrate_Types_CellState old =
    case old of
        Evergreen.V37.Types.CSEdit ->
            Evergreen.V40.Types.CSEdit

        Evergreen.V37.Types.CSView ->
            Evergreen.V40.Types.CSView


migrate_Types_ToBackend : Evergreen.V37.Types.ToBackend -> Evergreen.V40.Types.ToBackend
migrate_Types_ToBackend old =
    case old of
        Evergreen.V37.Types.NoOpToBackend ->
            Evergreen.V40.Types.NoOpToBackend

        Evergreen.V37.Types.RunTask ->
            Evergreen.V40.Types.RunTask

        Evergreen.V37.Types.SendUsers ->
            Evergreen.V40.Types.SendUsers

        Evergreen.V37.Types.CreateNotebook p0 p1 ->
            Evergreen.V40.Types.CreateNotebook p0 p1

        Evergreen.V37.Types.SaveNotebook p0 ->
            Evergreen.V40.Types.SaveNotebook (p0 |> migrate_Types_Book)

        Evergreen.V37.Types.DeleteNotebook p0 ->
            Evergreen.V40.Types.DeleteNotebook (p0 |> migrate_Types_Book)

        Evergreen.V37.Types.GetClonedNotebook p0 p1 ->
            Evergreen.V40.Types.GetClonedNotebook p0 p1

        Evergreen.V37.Types.GetPulledNotebook p0 p1 ->
            Evergreen.V40.Types.GetPulledNotebook p0
                p1
                "a"
                "b"

        Evergreen.V37.Types.UpdateSlugDict p0 ->
            Evergreen.V40.Types.UpdateSlugDict (p0 |> migrate_Types_Book)

        Evergreen.V37.Types.GetUsersNotebooks p0 ->
            Evergreen.V40.Types.GetUsersNotebooks p0

        Evergreen.V37.Types.GetPublicNotebooks p0 ->
            Evergreen.V40.Types.GetPublicNotebooks p0

        Evergreen.V37.Types.SignUpBE p0 p1 p2 ->
            Evergreen.V40.Types.SignUpBE p0 p1 p2

        Evergreen.V37.Types.SignInBEDev ->
            Evergreen.V40.Types.SignInBEDev

        Evergreen.V37.Types.SignInBE p0 p1 ->
            Evergreen.V40.Types.SignInBE p0 p1

        Evergreen.V37.Types.SignOutBE p0 ->
            Evergreen.V40.Types.SignOutBE p0

        Evergreen.V37.Types.UpdateUserWith p0 ->
            Evergreen.V40.Types.UpdateUserWith (p0 |> migrate_User_User)


migrate_User_User : Evergreen.V37.User.User -> Evergreen.V40.User.User
migrate_User_User old =
    old
