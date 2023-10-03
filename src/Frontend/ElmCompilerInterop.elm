module Frontend.ElmCompilerInterop exposing
    ( handleReplyFromElmCompiler
    , receiveReplDataFromJS
    )

import Codec
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
            let
                _ =
                    Debug.log "@@TYPE" replData.tipe
            in
            case model.currentCell of
                Nothing ->
                    ( { model | message = "Error: no cell found or ReceivedFromJS" }, Cmd.none )

                Just cell ->
                    let
                        newCell =
                            { cell | value = CVString replData.value, replData = Just replData }

                        newBook =
                            Notebook.Book.replaceCell newCell model.currentBook
                    in
                    ( { model | currentCell = Nothing, currentBook = newBook }, Cmd.none )

        Err _ ->
            ( { model | message = "Error evaluating Elm code" }, Cmd.none )


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

            else if str == "indent" then
                ( { model
                    | currentBook =
                        Notebook.Book.setReplDataAt model.currentCellIndex
                            (Just [ Notebook.Types.Plain "ERROR — maybe indentation, maybe something else." ])
                            model.currentBook
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
