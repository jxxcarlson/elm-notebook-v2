module Frontend.ElmCompilerInterop exposing
    ( handleReplyFromElmCompiler
    , receiveReplDataFromJS
    )

import Codec
import Dict
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
    let
        _ =
            Debug.log "@@receiveReplDataFromJS" str
    in
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

                        newJsCodeDict =
                            Dict.insert newCell.id replData.value model.jsCodeDict
                    in
                    ( { model
                        | currentCell = Just newCell
                        , currentBook = newBook
                        , jsCodeDict = newJsCodeDict
                      }
                    , Cmd.none
                    )

        Err _ ->
            ( { model | message = "Error evaluating Elm code" }, Cmd.none )


handleReplyFromElmCompiler model cell result =
    case result of
        Ok str ->
            let
                _ =
                    Debug.log "@@handleReplyFromElmCompiler" str
            in
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
                let
                    _ =
                        Debug.log "@@Sending data to JS" "!!!"
                in
                ( { model
                    | currentCell = Just cell
                    , currentBook = Notebook.Book.replaceCell { cell | replData = Nothing } model.currentBook
                    , jsCodeDict =
                        if String.contains "svg" cell.text then
                            Dict.insert cell.id str model.jsCodeDict

                        else
                            model.jsCodeDict
                  }
                , if String.contains "svg" cell.text then
                    Cmd.none

                  else
                    Ports.sendDataToJS str
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
