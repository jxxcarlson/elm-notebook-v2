module Frontend.ElmCompilerInterop exposing
    ( handleReplyFromElmCompiler
    , receiveReplDataFromJS
    )

import Codec
import Message
import Notebook.Book
import Notebook.Cell exposing (CellValue(..))
import Notebook.Eval
import Notebook.Types
import Ports
import Types


type alias Model =
    Types.FrontendModel


type alias Msg =
    Types.FrontendMsg


receiveReplDataFromJS : Model -> String -> ( Model, Cmd Msg )
receiveReplDataFromJS model str =
    case Codec.decodeString Notebook.Eval.replDataCodec str of
        Ok replData ->
            case model.currentCell of
                Nothing ->
                    Message.postMessage "Error: no cell found or ReceivedFromJS" Types.MSRed model

                Just cell ->
                    let
                        newCell =
                            { cell | value = CVString replData.value, replData = Just replData }

                        newBook =
                            Notebook.Book.replaceCell newCell model.currentBook
                    in
                    ( { model | currentCell = Nothing, currentBook = newBook }, Cmd.none )

        Err _ ->
            Message.postMessage "Error evaluating Elm code" Types.MSRed model


handleReplyFromElmCompiler model cell result =
    case result of
        Ok str ->
            if Notebook.Eval.hasReplError str then
                let
                    newCell =
                        { cell | report = Just <| Notebook.Eval.reportError str }

                    newBook =
                        Notebook.Book.replaceCell newCell model.currentBook
                in
                ( { model
                    | currentBook = newBook
                  }
                , Cmd.none
                )

            else
                ( { model
                    | currentCell = Just cell
                    , currentBook = Notebook.Book.replaceCell { cell | replData = Nothing } model.currentBook
                  }
                , Ports.sendDataToJS str
                )

        Err _ ->
            ( { model
                | currentBook =
                    Notebook.Book.setReplDataAt model.currentCellIndex
                        Nothing
                        model.currentBook
              }
            , Cmd.none
            )
