module Evergreen.V4.Authentication exposing (..)

import Dict
import Evergreen.V4.Credentials
import Evergreen.V4.User


type alias Username =
    String


type alias UserData =
    { user : Evergreen.V4.User.User
    , credentials : Evergreen.V4.Credentials.Credentials
    }


type alias AuthenticationDict =
    Dict.Dict Username UserData
