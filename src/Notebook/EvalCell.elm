module Notebook.EvalCell exposing
    ( executeCell
    , executeNotebook
    , processCell
    , updateEvalStateWithCells
    )

import Dict
import List.Extra
import Message
import Notebook.Book
import Notebook.Cell as Cell exposing (Cell, CellState(..), CellType(..), CellValue(..))
import Notebook.CellHelper
import Notebook.Eval as Eval
import Notebook.Parser
import Notebook.Types exposing (EvalState)
import Process
import Task
import Types exposing (FrontendMsg)
import Util


type alias Model =
    Types.FrontendModel



-- EXECUTE NOTEBOOK


executeNotebook : Model -> ( Model, Cmd FrontendMsg )
executeNotebook model =
    let
        currentBook =
            model.currentBook

        -- Close all cells and set report and replData to Nothing
        newBook =
            { currentBook
                | cells =
                    List.map
                        (\cell ->
                            { cell
                                | value = CVNone
                                , report = Nothing
                                , replData = Nothing
                                , cellState = CSView
                            }
                        )
                        currentBook.cells
            }

        newEvalState =
            updateEvalStateWithCells currentBook.cells Notebook.Types.emptyEvalState

        indices =
            List.range 0 (List.length model.currentBook.cells)

        commands =
            List.indexedMap createDelayedCommand indices
    in
    ( { model
        | currentBook = newBook
        , books =
            List.map
                (\book ->
                    if book.id == currentBook.id then
                        newBook

                    else
                        book
                )
                model.books
        , evalState = newEvalState
      }
    , Cmd.batch commands
    )


createDelayedCommand : Int -> Int -> Cmd FrontendMsg
createDelayedCommand idx _ =
    Process.sleep (toFloat (idx * 50))
        |> Task.perform (\_ -> Types.ExecuteCell idx)


executeCell : Int -> Model -> ( Model, Cmd FrontendMsg )
executeCell cellIndex model =
    case List.Extra.getAt cellIndex model.currentBook.cells of
        Nothing ->
            ( model, Cmd.none )

        Just cell ->
            case cell.tipe of
                Cell.CTCode ->
                    case Notebook.Parser.classify cell.text of
                        Err _ ->
                            Message.postMessage "Error decoding imported file (1)" Types.MSRed model

                        Ok classif ->
                            case classif of
                                Notebook.Parser.Expr sourceText ->
                                    let
                                        cleanCell =
                                            { cell | report = Nothing, replData = Nothing, value = CVNone }

                                        cleanBook =
                                            Notebook.CellHelper.updateBookWithCell cleanCell model.currentBook

                                        newEvalState =
                                            updateEvalStateWithCells cleanBook.cells Notebook.Types.emptyEvalState
                                    in
                                    ( { model
                                        | currentCell = Just cleanCell
                                        , currentBook = cleanBook
                                        , evalState = newEvalState
                                      }
                                    , Eval.requestEvaluation newEvalState cell (sourceText |> Util.compressNewlines |> String.trim)
                                    )

                                _ ->
                                    ( model, Cmd.none )

                Cell.CTMarkdown ->
                    ( model, Cmd.none )



-- UPDATE DECLARATIONS DICTIONARY


updateEvalStateWithCells : List Cell -> EvalState -> EvalState
updateEvalStateWithCells cells evalState =
    List.foldl updateEvalStateWithCell evalState cells


updateEvalStateWithCell : Cell -> EvalState -> EvalState
updateEvalStateWithCell cell evalState =
    case cell.tipe of
        Cell.CTMarkdown ->
            evalState

        Cell.CTCode ->
            case Notebook.Parser.classify cell.text of
                Err _ ->
                    evalState

                Ok classif ->
                    case classif of
                        Notebook.Parser.Expr _ ->
                            evalState

                        Notebook.Parser.Decl name sourceText ->
                            Eval.insertDeclaration name (name ++ " = " ++ sourceText ++ "\n") evalState

                        Notebook.Parser.ElmType name expr ->
                            Eval.insertTypeDeclaration name ("type " ++ name ++ " = " ++ expr ++ "\n") evalState

                        Notebook.Parser.TypeAlias name expr ->
                            Eval.insertTypeDeclaration name ("type alias " ++ name ++ " = " ++ expr ++ "\n") evalState

                        Notebook.Parser.Import name expr ->
                            Eval.insertImport name ("import " ++ name ++ " " ++ expr ++ "\n") evalState



-- PROCESS CELL


processCell : CellState -> Int -> Model -> ( Model, Cmd FrontendMsg )
processCell cellState cellIndex model_ =
    -- TODO
    let
        model =
            case cellState of
                CSEdit ->
                    model_

                CSView ->
                    { model_ | currentBook = Notebook.Book.setAllCellStates CSView model_.currentBook }
    in
    case List.Extra.getAt cellIndex model.currentBook.cells of
        Nothing ->
            ( model, Cmd.none )

        Just cell ->
            case cell.tipe of
                Cell.CTCode ->
                    processCode model { cell | report = Nothing, replData = Nothing, cellState = CSView }

                Cell.CTMarkdown ->
                    processMarkdown model { cell | cellState = CSView }


processMarkdown model cell =
    let
        newCell =
            { cell | value = CVMarkdown cell.text }

        newBook =
            Notebook.CellHelper.updateBookWithCell newCell model.currentBook
    in
    ( { model | currentBook = newBook }, Cmd.none )


processCode : Model -> Cell -> ( Model, Cmd FrontendMsg )
processCode model cell =
    case Notebook.Parser.classify cell.text of
        Err _ ->
            Message.postMessage "Parse error in processCode" Types.MSRed model

        Ok classif ->
            case classif of
                Notebook.Parser.Expr sourceText ->
                    processExpr model cell sourceText

                Notebook.Parser.Decl name sourceText ->
                    processDeclaration model cell name sourceText

                Notebook.Parser.Import name sourceText ->
                    processImport model cell name sourceText

                Notebook.Parser.TypeAlias name sourceText ->
                    processTypeAliasDeclaration model cell name sourceText

                Notebook.Parser.ElmType name sourceText ->
                    processTypeDeclaration model cell name sourceText


processExpr : Model -> Cell -> String -> ( Model, Cmd FrontendMsg )
processExpr model cell sourceText =
    let
        newEvalState =
            updateEvalStateWithCells model.currentBook.cells Notebook.Types.emptyEvalState
    in
    ( model, Eval.requestEvaluation newEvalState cell sourceText )


processDeclaration : Model -> Cell -> String -> String -> ( Model, Cmd FrontendMsg )
processDeclaration model cell name expr =
    let
        newEvalState =
            Eval.insertDeclaration name (name ++ " = " ++ expr ++ "\n") model.evalState

        newCell =
            { cell | cellState = CSView }

        newBook =
            Notebook.CellHelper.updateBookWithCell newCell model.currentBook
    in
    ( { model | evalState = newEvalState, currentCell = Just newCell, currentBook = newBook }, Cmd.none )


processImport : Model -> Cell -> String -> String -> ( Model, Cmd FrontendMsg )
processImport model cell name expr =
    let
        newEvalState =
            Eval.insertImport name ("import " ++ name ++ " " ++ expr ++ "\n") model.evalState

        newCell =
            { cell | cellState = CSView }

        newBook =
            Notebook.CellHelper.updateBookWithCell newCell model.currentBook
    in
    ( { model
        | evalState = newEvalState
        , currentCell = Just newCell
        , currentBook = newBook
      }
    , Cmd.none
    )


processTypeDeclaration : Model -> Cell -> String -> String -> ( Model, Cmd FrontendMsg )
processTypeDeclaration model cell name expr =
    let
        newEvalState =
            Eval.insertTypeDeclaration name ("type " ++ name ++ " = " ++ expr ++ "\n") model.evalState

        newCell =
            { cell | cellState = CSView }

        newBook =
            Notebook.CellHelper.updateBookWithCell newCell model.currentBook
    in
    ( { model
        | evalState = newEvalState
        , currentCell = Just newCell
        , currentBook = newBook
      }
    , Cmd.none
    )


processTypeAliasDeclaration : Model -> Cell -> String -> String -> ( Model, Cmd FrontendMsg )
processTypeAliasDeclaration model cell name expr =
    let
        newEvalState =
            Eval.insertTypeDeclaration name ("type alias " ++ name ++ " = " ++ expr ++ "\n") model.evalState

        newCell =
            { cell | cellState = CSView }

        newBook =
            Notebook.CellHelper.updateBookWithCell newCell model.currentBook
    in
    ( { model
        | evalState = newEvalState
        , currentCell = Just newCell
        , currentBook = newBook
      }
    , Cmd.none
    )
