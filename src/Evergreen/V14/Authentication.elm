module Evergreen.V14.Authentication exposing (..)

import Dict
import Evergreen.V14.Credentials
import Evergreen.V14.User


type alias Username =
    String


type alias UserData =
    { user : Evergreen.V14.User.User
    , credentials : Evergreen.V14.Credentials.Credentials
    }


type alias AuthenticationDict =
    Dict.Dict Username UserData
