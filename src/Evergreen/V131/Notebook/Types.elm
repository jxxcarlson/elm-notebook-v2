module Evergreen.V131.Notebook.Types exposing (..)

import Dict


type alias StyledString =
    { bold : Bool
    , underline : Bool
    , color : Maybe String
    , string : String
    }


type MessageItem
    = Plain String
    | Styled StyledString


type alias ReplData =
    { name : Maybe String
    , value : String
    , tipe : String
    }


type alias ErrorReport =
    ( Int, List MessageItem )


type alias EvalState =
    { decls : Dict.Dict String String
    , types : Dict.Dict String String
    , imports : Dict.Dict String String
    }


type alias ElmPackageSummary =
    { dependencies : Dict.Dict String String
    , exposedModules : List String
    , name : String
    , version : String
    }


type CellDirection
    = Up
    | Down


type alias SimplePackageInfo =
    { name : String
    , version : String
    }
