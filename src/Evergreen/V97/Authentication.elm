module Evergreen.V97.Authentication exposing (..)

import Dict
import Evergreen.V97.Credentials
import Evergreen.V97.User


type alias Username =
    String


type alias UserData =
    { user : Evergreen.V97.User.User
    , credentials : Evergreen.V97.Credentials.Credentials
    }


type alias AuthenticationDict =
    Dict.Dict Username UserData
