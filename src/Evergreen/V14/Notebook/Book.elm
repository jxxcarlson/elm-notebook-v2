module Evergreen.V14.Notebook.Book exposing (..)

import Evergreen.V14.Notebook.Cell
import Time


type Theme
    = DarkTheme
    | LightTheme


type alias Book =
    { id : String
    , dirty : Bool
    , slug : String
    , origin : Maybe String
    , author : String
    , createdAt : Time.Posix
    , updatedAt : Time.Posix
    , public : Bool
    , title : String
    , cells : List Evergreen.V14.Notebook.Cell.Cell
    , currentIndex : Int
    , packageNames : List String
    }


type DirectionToMove
    = Up
    | Down
