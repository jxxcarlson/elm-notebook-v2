module Frontend.ElmCompilerInterop exposing
    ( handleReplyFromElmCompiler
    , handleReplyFromElmCompiler2
    , receiveReplDataFromJS
    )

import Codec
import List.Extra
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
                    Message.postMessage "E.2" Types.MSYellow model

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
                        { cell | report = ( cell.index, Just <| Notebook.Eval.reportError str ) }

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


handleReplyFromElmCompiler2 model k result =
    case result of
        Ok str ->
            case List.Extra.getAt k model.currentBook.cells of
                Nothing ->
                    ( model, Cmd.none )

                Just oldCell ->
                    if Notebook.Eval.hasReplError str then
                        let
                            newCell =
                                { oldCell | report = ( oldCell.index, Just <| Notebook.Eval.reportError str ) }

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
                            | currentCell = Just oldCell
                            , currentBook = Notebook.Book.replaceCell { oldCell | replData = Nothing } model.currentBook
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
