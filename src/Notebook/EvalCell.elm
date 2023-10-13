module Notebook.EvalCell exposing
    ( executeCell
    , executeNotebook
    , processCell
    , updateEvalStateWithCells
    )

import Dict
import List.Extra
import Notebook.Book
import Notebook.Cell as Cell exposing (Cell, CellState(..), CellType(..), CellValue(..))
import Notebook.CellHelper
import Notebook.Eval as Eval
import Notebook.Parser
import Notebook.Types exposing (EvalState)
import Process
import Task
import Types exposing (FrontendMsg)


type alias Model =
    Types.FrontendModel



-- EXECUTE NOTEBOOK


executeNotebook : Model -> ( Model, Cmd FrontendMsg )
executeNotebook model_ =
    let
        currentBook =
            model_.currentBook

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
            updateEvalStateWithCells newBook.cells Notebook.Types.emptyEvalState

        _ =
            Debug.log "__TYPES, from book" newEvalState.types

        _ =
            Debug.log "__IMPORTS, from book" newEvalState.imports

        _ =
            Debug.log "__DECLS, from book" newEvalState.decls

        model =
            { model_ | currentBook = newBook, evalState = newEvalState }

        n =
            List.length model.currentBook.cells

        indices =
            List.range 0 n

        commands =
            List.indexedMap createDelayedCommand indices
    in
    ( model, Cmd.batch commands )


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
                            ( { model | message = "Parse error (Cell)" }, Cmd.none )

                        Ok classif ->
                            case classif of
                                Notebook.Parser.Expr sourceText ->
                                    let
                                        cleanCell =
                                            { cell | report = Nothing, replData = Nothing, value = CVNone }

                                        cleanBook =
                                            Notebook.CellHelper.updateBookWithCell cleanCell model.currentBook
                                    in
                                    ( { model | currentCell = Just cleanCell, currentBook = cleanBook }
                                    , Eval.requestEvaluation model.evalState cell sourceText
                                    )

                                Notebook.Parser.Decl _ _ ->
                                    ( model, Cmd.none )

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
                    processCode model { cell | report = Nothing, replData = Nothing }

                Cell.CTMarkdown ->
                    processMarkdown model cell


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
            ( { model | message = "Parse error (22)3" }, Cmd.none )

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
    if String.left 6 sourceText == ":clear" then
        processClearCmd model

    else if String.left 7 sourceText == ":remove" then
        processRemoveCmd model sourceText

    else
        ( model, Eval.requestEvaluation model.evalState cell sourceText )


processClearCmd model =
    let
        evalState =
            model.evalState
    in
    ( { model
        | evalState = { evalState | decls = Dict.empty }
      }
    , Cmd.none
    )


processRemoveCmd : Model -> String -> ( Model, Cmd FrontendMsg )
processRemoveCmd model expr =
    let
        key =
            String.dropLeft 8 expr |> String.trim
    in
    case Dict.get key model.evalState.decls of
        Just _ ->
            ( { model
                | evalState = Eval.removeDeclaration key model.evalState
              }
            , Cmd.none
            )

        Nothing ->
            ( model, Cmd.none )


processDeclaration : Model -> Cell -> String -> String -> ( Model, Cmd FrontendMsg )
processDeclaration model cell name expr =
    let
        newEvalState =
            Eval.insertDeclaration name (name ++ " = " ++ expr ++ "\n") model.evalState
    in
    ( { model | evalState = newEvalState }, Cmd.none )


processImport : Model -> Cell -> String -> String -> ( Model, Cmd FrontendMsg )
processImport model cell name expr =
    let
        newEvalState =
            Eval.insertImport name ("import " ++ name ++ " " ++ expr ++ "\n") model.evalState
    in
    ( { model | evalState = newEvalState }, Cmd.none )


processTypeDeclaration : Model -> Cell -> String -> String -> ( Model, Cmd FrontendMsg )
processTypeDeclaration model cell name expr =
    let
        newEvalState =
            Eval.insertTypeDeclaration name ("type " ++ name ++ " = " ++ expr ++ "\n") model.evalState
    in
    ( { model | evalState = newEvalState }, Cmd.none )


processTypeAliasDeclaration : Model -> Cell -> String -> String -> ( Model, Cmd FrontendMsg )
processTypeAliasDeclaration model cell name expr =
    let
        newEvalState =
            Eval.insertTypeDeclaration name ("type alias " ++ name ++ " = " ++ expr ++ "\n") model.evalState
    in
    ( { model | evalState = newEvalState }, Cmd.none )
