module Config exposing (appUrl)

import Env


appUrl =
    case Env.mode of
        Env.Development ->
            "http://localhost:8000"

        Env.Production ->
            "https://elm-notebook.org"


administrator =
    "jxxcarlson@gmail.com"


imageServUrl =
    "https://pdfServ.app/a/image"


helpDocumentId =
    "yr248.qb459"
