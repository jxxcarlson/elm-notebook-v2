module Evergreen.V140.Authentication exposing (..)

import Dict
import Evergreen.V140.Credentials
import Evergreen.V140.User


type alias Username =
    String


type alias UserData =
    { user : Evergreen.V140.User.User
    , credentials : Evergreen.V140.Credentials.Credentials
    }


type alias AuthenticationDict =
    Dict.Dict Username UserData
