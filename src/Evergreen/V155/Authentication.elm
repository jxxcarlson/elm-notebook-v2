module Evergreen.V155.Authentication exposing (..)

import Dict
import Evergreen.V155.Credentials
import Evergreen.V155.User


type alias Username =
    String


type alias UserData =
    { user : Evergreen.V155.User.User
    , credentials : Evergreen.V155.Credentials.Credentials
    }


type alias AuthenticationDict =
    Dict.Dict Username UserData
