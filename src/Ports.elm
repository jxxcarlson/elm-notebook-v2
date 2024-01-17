port module Ports exposing
    ( decodeIndexAndSourcePair
    , encodeIndexAndSourcePair
    , receiveFromJS
    , receiveJSData
    , sendData
    , sendDataToJS
    , sendJSData
    , supermario_copy_to_clipboard_to_js
    )

import Json.Decode as Decode
import Json.Encode as Encode


port sendDataToJS : String -> Cmd msg


port receiveFromJS : (String -> msg) -> Sub msg


port sendJSData : Encode.Value -> Cmd msg


port receiveJSData : (String -> msg) -> Sub msg


port sendData : String -> Cmd msg


port supermario_copy_to_clipboard_to_js : Decode.Value -> Cmd msg


encodeIndexAndSourcePair : ( Int, String ) -> Encode.Value
encodeIndexAndSourcePair ( index, source ) =
    Encode.object
        [ ( "index", Encode.int index )
        , ( "source", Encode.string source )
        ]


decodeIndexAndSourcePair : Decode.Value -> Result Decode.Error ( Int, String )
decodeIndexAndSourcePair value =
    Decode.decodeValue indexAndSourcePairDecoder value


indexAndSourcePairDecoder : Decode.Decoder ( Int, String )
indexAndSourcePairDecoder =
    Decode.map2 (\a b -> ( a, b )) (Decode.field "index" Decode.int) (Decode.field "source" Decode.string)
