module Notebook.Types exposing
    ( CellDirection(..)
    , ElmPackage
    , ElmPackageSummary
    , EvalState
    , ExposedModules
    , MessageItem(..)
    , Package
    , PackageList
    , ReplData
    , StyledString
    )

import Dict exposing (Dict)


type alias ElmPackage =
    { packageType : String
    , name : String
    , summary : String
    , license : String
    , version : String
    , exposedModules : List String -- (not Exposed Modules)
    , elmVersion : String
    , dependencies : Dict String String
    , testDependencies : Dict String String
    }


type alias ElmPackageSummary =
    { dependencies : Dict String String
    , exposedModules : List String
    , name : String
    , version : String
    }


type alias ExposedModules =
    Dict String (List String)



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
