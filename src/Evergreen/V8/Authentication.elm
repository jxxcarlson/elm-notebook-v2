module Evergreen.V8.Authentication exposing (..)

import Dict
import Evergreen.V8.Credentials
import Evergreen.V8.User


type alias Username =
    String


type alias UserData =
    { user : Evergreen.V8.User.User
    , credentials : Evergreen.V8.Credentials.Credentials
    }


type alias AuthenticationDict =
    Dict.Dict Username UserData
