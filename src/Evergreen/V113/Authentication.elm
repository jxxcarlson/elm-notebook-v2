module Evergreen.V113.Authentication exposing (..)

import Dict
import Evergreen.V113.Credentials
import Evergreen.V113.User


type alias Username =
    String


type alias UserData =
    { user : Evergreen.V113.User.User
    , credentials : Evergreen.V113.Credentials.Credentials
    }


type alias AuthenticationDict =
    Dict.Dict Username UserData
