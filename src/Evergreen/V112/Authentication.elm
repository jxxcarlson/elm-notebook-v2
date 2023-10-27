module Evergreen.V112.Authentication exposing (..)

import Dict
import Evergreen.V112.Credentials
import Evergreen.V112.User


type alias Username =
    String


type alias UserData =
    { user : Evergreen.V112.User.User
    , credentials : Evergreen.V112.Credentials.Credentials
    }


type alias AuthenticationDict =
    Dict.Dict Username UserData
