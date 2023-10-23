module Notebook.EvalCell exposing
    ( executeCell
    , executeCellCommand
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
import Notebook.Config
import Notebook.ErrorReporter
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
                                , report = ( cell.index, Nothing )
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
            List.indexedMap (\k index -> createDelayedCommand2 k (Types.ExecuteCell index)) indices

        errorReportDelay =
            1 + List.length indices

        delayedCollateErrorReportsCmd =
            createDelayedCommand2 errorReportDelay Types.UpdateErrorReports
    in
    ( { model
        | currentBook = newBook |> Notebook.Book.clearValues
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
        , errorReports = []
      }
    , Cmd.batch (delayedCollateErrorReportsCmd :: commands)
    )


executeNotebookWithTasks : Model -> ( Model, Cmd FrontendMsg )
executeNotebookWithTasks model =
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
                                , report = ( cell.index, Nothing )
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

        tasks =
            List.indexedMap (\k index -> createDelayedCommand2 k (Types.ExecuteCell index)) indices

        -- requestEvaluationAsTask evalState expr
        errorReportDelay =
            1 + List.length indices

        delayedCollateErrorReportsCmd =
            createDelayedCommand2 errorReportDelay Types.UpdateErrorReports
    in
    ( { model
        | currentBook = newBook |> Notebook.Book.clearValues
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
        , errorReports = []
      }
    , Cmd.none
    )


createDelayedCommand2 : Int -> FrontendMsg -> Cmd FrontendMsg
createDelayedCommand2 delay msg =
    Process.sleep (toFloat (delay * Notebook.Config.delay))
        |> Task.perform (\_ -> msg)


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
                                            { cell | report = ( cell.index, Nothing ), replData = Nothing, value = CVNone }

                                        cleanBook =
                                            Notebook.CellHelper.updateBookWithCell cleanCell model.currentBook

                                        newEvalState =
                                            updateEvalStateWithCells cleanBook.cells Notebook.Types.emptyEvalState
                                    in
                                    ( { model
                                        | currentCell = Just cleanCell
                                        , currentBook = cleanBook
                                        , evalState = newEvalState |> Debug.log "@@EvalState"
                                      }
                                    , Eval.requestEvaluation newEvalState cell sourceText
                                    )

                                _ ->
                                    ( model, Cmd.none )

                Cell.CTMarkdown ->
                    ( model, Cmd.none )


executeCellCommand : Int -> Model -> Cmd FrontendMsg
executeCellCommand cellIndex model =
    case List.Extra.getAt cellIndex model.currentBook.cells of
        Nothing ->
            Cmd.none

        Just cell ->
            case cell.tipe of
                Cell.CTCode ->
                    case Notebook.Parser.classify cell.text of
                        Err _ ->
                            Cmd.none

                        Ok classif ->
                            case classif of
                                Notebook.Parser.Expr sourceText ->
                                    Eval.requestEvaluation model.evalState cell sourceText

                                _ ->
                                    Cmd.none

                Cell.CTMarkdown ->
                    Cmd.none



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
            case Notebook.Parser.classify (compress cell.text) of
                Err _ ->
                    evalState

                Ok classif ->
                    case classif of
                        Notebook.Parser.Expr _ ->
                            evalState

                        Notebook.Parser.Decl name sourceText_ ->
                            let
                                sourceText =
                                    fixLet sourceText_
                            in
                            Eval.insertDeclaration name (name ++ " = " ++ sourceText ++ "\n") evalState

                        Notebook.Parser.ElmType name expr ->
                            Eval.insertTypeDeclaration name ("type " ++ name ++ " = " ++ expr ++ "\n") evalState

                        Notebook.Parser.TypeAlias name expr ->
                            Eval.insertTypeDeclaration name ("type alias " ++ name ++ " = " ++ expr ++ "\n") evalState

                        Notebook.Parser.Import name expr ->
                            Eval.insertImport name ("import " ++ name ++ " " ++ expr ++ "\n") evalState


fixLet str =
    if String.left 3 str == "let" then
        "\n  " ++ str

    else
        str


compress str =
    str |> Util.compressNewlines |> String.trim



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
                    processCode model { cell | report = ( cell.index, Nothing ), replData = Nothing, cellState = CSView }

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
