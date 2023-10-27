module Evergreen.V107.Authentication exposing (..)

import Dict
import Evergreen.V107.Credentials
import Evergreen.V107.User


type alias Username =
    String


type alias UserData =
    { user : Evergreen.V107.User.User
    , credentials : Evergreen.V107.Credentials.Credentials
    }


type alias AuthenticationDict =
    Dict.Dict Username UserData
