module Evergreen.V9.Notebook.Book exposing (..)

import Evergreen.V9.Notebook.Cell
import Time


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
    , cells : List Evergreen.V9.Notebook.Cell.Cell
    , currentIndex : Int
    , packageNames : List String
    }
