module Notebook.Types exposing
    ( CellDirection(..)
    , EvalState
    , MessageItem(..)
    , Package
    , PackageList
    , ReplData
    , StyledString
    )

import Dict exposing (Dict)



--
--type alias ElmJsonDict =
--    Dict String String


type alias PackageList =
    List Package


type alias Package =
    { name : String
    , version : String
    }


type alias EvalState =
    { decls : Dict String String
    , types : Dict String String
    , imports : Dict String String
    }


type alias ReplData =
    { name : Maybe String
    , value : String
    , tipe : String
    }


type CellDirection
    = Up
    | Down


type MessageItem
    = Plain String
    | Styled StyledString


type alias StyledString =
    { bold : Bool
    , underline : Bool
    , color : Maybe String
    , string : String
    }
