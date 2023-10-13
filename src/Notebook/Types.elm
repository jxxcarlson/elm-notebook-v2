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
    , SimplePackageInfo
    , StyledString
    , cleanElmPackageSummary
    , emptyEvalState
    )

import Dict exposing (Dict)


type alias SimplePackageInfo =
    { name : String
    , version : String
    }


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


cleanElmPackageSummary : ElmPackageSummary -> ElmPackageSummary
cleanElmPackageSummary summary =
    { summary | dependencies = Dict.remove "elm/core" summary.dependencies } |> Debug.log "CLEAN_DEPENDENCIES"


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


emptyEvalState : EvalState
emptyEvalState =
    { decls = Dict.empty
    , types = Dict.empty
    , imports = Dict.empty
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
