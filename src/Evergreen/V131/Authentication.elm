module Evergreen.V131.Authentication exposing (..)

import Dict
import Evergreen.V131.Credentials
import Evergreen.V131.User


type alias Username =
    String


type alias UserData =
    { user : Evergreen.V131.User.User
    , credentials : Evergreen.V131.Credentials.Credentials
    }


type alias AuthenticationDict =
    Dict.Dict Username UserData
