module Evergreen.V132.Authentication exposing (..)

import Dict
import Evergreen.V132.Credentials
import Evergreen.V132.User


type alias Username =
    String


type alias UserData =
    { user : Evergreen.V132.User.User
    , credentials : Evergreen.V132.Credentials.Credentials
    }


type alias AuthenticationDict =
    Dict.Dict Username UserData
