module Evergreen.V151.Authentication exposing (..)

import Dict
import Evergreen.V151.Credentials
import Evergreen.V151.User


type alias Username =
    String


type alias UserData =
    { user : Evergreen.V151.User.User
    , credentials : Evergreen.V151.Credentials.Credentials
    }


type alias AuthenticationDict =
    Dict.Dict Username UserData
