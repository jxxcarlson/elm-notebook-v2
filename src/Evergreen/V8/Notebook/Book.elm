module Evergreen.V8.Notebook.Book exposing (..)

import Evergreen.V8.Notebook.Cell
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
    , cells : List Evergreen.V8.Notebook.Cell.Cell
    , currentIndex : Int
    }
