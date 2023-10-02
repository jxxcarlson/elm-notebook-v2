module Backend.Utility exposing (getUniqueIdentifier)

import Dict exposing (Dict)


getUniqueIdentifier : String -> Dict String a -> String
getUniqueIdentifier id dict =
    case Dict.get id dict of
        Nothing ->
            id

        Just _ ->
            getUniqueIdentifier_ 1 id dict


getUniqueIdentifier_ : Int -> String -> Dict String a -> String
getUniqueIdentifier_ counter id dict =
    case Dict.get (id ++ "-" ++ String.fromInt counter) dict of
        Nothing ->
            id ++ "-" ++ String.fromInt counter

        Just _ ->
            getUniqueIdentifier_ (counter + 1) id dict
