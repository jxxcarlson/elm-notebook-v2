module Evergreen.V82.Notebook.Book exposing (..)

import Dict
import Evergreen.V82.Notebook.Cell
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
    , cells : List Evergreen.V82.Notebook.Cell.Cell
    , currentIndex : Int
    , packageNames : List String
    , tags : List String
    , options : Dict.Dict String String
    }


type DirectionToMove
    = Up
    | Down
