module Evergreen.V151.Session exposing (..)

import Dict
import Lamdera
import Time


type Interaction
    = ISignIn Time.Posix
    | ISignOut Time.Posix
    | ISignUp Time.Posix


type alias SessionInfo =
    Dict.Dict Lamdera.SessionId Interaction
