module Evergreen.V145.Authentication exposing (..)

import Dict
import Evergreen.V145.Credentials
import Evergreen.V145.User


type alias Username =
    String


type alias UserData =
    { user : Evergreen.V145.User.User
    , credentials : Evergreen.V145.Credentials.Credentials
    }


type alias AuthenticationDict =
    Dict.Dict Username UserData
