module Frontend.ElmCompilerInterop exposing
    ( handleReplyFromElmCompiler
    , receiveReplDataFromJS
    , updateCell
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


handleReplyFromElmCompiler : Model -> Notebook.Cell.Cell -> Result error String -> ( Model, Cmd Types.FrontendMsg )
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


updateCell : Model -> Int -> String -> List Notebook.Cell.Cell -> ( Model -> Model, Cmd Types.FrontendMsg )
updateCell model index str cells =
    let
        mCell =
            List.Extra.getAt index cells
    in
    case mCell of
        Nothing ->
            ( identity, Cmd.none )

        Just cell ->
            if Notebook.Eval.hasReplError str then
                let
                    newCell =
                        { cell | report = ( cell.index, Just <| Notebook.Eval.reportError str ) }

                    newBook =
                        Notebook.Book.replaceCell newCell model.currentBook
                in
                ( \model_ ->
                    { model
                        | currentBook = newBook
                    }
                , Cmd.none
                )

            else
                ( \model_ ->
                    { model
                        | currentCell = Just cell
                        , currentBook = Notebook.Book.replaceCell { cell | replData = Nothing } model.currentBook
                    }
                , Ports.sendDataToJS str
                )
