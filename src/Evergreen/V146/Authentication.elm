module Evergreen.V146.Authentication exposing (..)

import Dict
import Evergreen.V146.Credentials
import Evergreen.V146.User


type alias Username =
    String


type alias UserData =
    { user : Evergreen.V146.User.User
    , credentials : Evergreen.V146.Credentials.Credentials
    }


type alias AuthenticationDict =
    Dict.Dict Username UserData
