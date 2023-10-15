module Evergreen.V22.Authentication exposing (..)

import Dict
import Evergreen.V22.Credentials
import Evergreen.V22.User


type alias Username =
    String


type alias UserData =
    { user : Evergreen.V22.User.User
    , credentials : Evergreen.V22.Credentials.Credentials
    }


type alias AuthenticationDict =
    Dict.Dict Username UserData
