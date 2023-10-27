module Evergreen.V109.Authentication exposing (..)

import Dict
import Evergreen.V109.Credentials
import Evergreen.V109.User


type alias Username =
    String


type alias UserData =
    { user : Evergreen.V109.User.User
    , credentials : Evergreen.V109.Credentials.Credentials
    }


type alias AuthenticationDict =
    Dict.Dict Username UserData
