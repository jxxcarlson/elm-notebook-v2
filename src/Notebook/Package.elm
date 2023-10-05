module Notebook.Package exposing (..)

import Http
import Notebook.Codec
import Notebook.Types
import Types


sendPackageList : Notebook.Types.PackageList -> Cmd Types.FrontendMsg
sendPackageList packageList =
    Http.post
        { url = "http://localhost:8009"
        , body = Http.jsonBody (Notebook.Codec.encodePackageList packageList)
        , expect = Http.expectWhatever Types.PackageListSent
        }
