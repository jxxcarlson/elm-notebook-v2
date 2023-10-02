module Notebook.EvalCell exposing
    ( executeCell
    , executeNotebok
    , processCell
    , updateDeclarationsDictionary
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


executeNotebok : Model -> ( Model, Cmd FrontendMsg )
executeNotebok model_ =
    let
        model =
            updateDeclarationsDictionary model_

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
                        Notebook.Parser.Expr sourceText ->
                            ( model, Eval.requestEvaluation model.evalState cell sourceText )

                        Notebook.Parser.Decl _ _ ->
                            ( model, Cmd.none )

                Cell.CTMarkdown ->
                    ( model, Cmd.none )



-- UPDATE DECLARATIONS DICTIONARY


updateDeclarationsDictionary : Model -> Model
updateDeclarationsDictionary model =
    let
        n =
            List.length model.currentBook.cells

        indices =
            List.range 0 n

        oldEvalState =
            model.evalState

        newEvalState =
            { oldEvalState | decls = Dict.empty }
    in
    List.foldl folder { model | evalState = newEvalState } indices


folder : Int -> Model -> Model
folder cellIndex model =
    case List.Extra.getAt cellIndex model.currentBook.cells of
        Nothing ->
            model

        Just cell ->
            updateDeclarationsDictionaryWithCell cell model


updateDeclarationsDictionaryWithCell : Cell -> Model -> Model
updateDeclarationsDictionaryWithCell cell model =
    case cell.tipe of
        Cell.CTMarkdown ->
            model

        Cell.CTCode ->
            case Notebook.Parser.classify cell.text of
                Notebook.Parser.Expr sourceText ->
                    model

                Notebook.Parser.Decl name sourceText ->
                    { model | evalState = Eval.insertDeclaration name (name ++ " = " ++ sourceText ++ "\n") model.evalState }



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
        Notebook.Parser.Expr sourceText ->
            processExpr model cell sourceText

        Notebook.Parser.Decl name sourceText ->
            processNameAndExpr model cell name sourceText


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


processNameAndExpr : Model -> Cell -> String -> String -> ( Model, Cmd FrontendMsg )
processNameAndExpr model cell name expr =
    let
        newEvalState =
            Eval.insertDeclaration name (name ++ " = " ++ expr ++ "\n") model.evalState
    in
    ( { model | evalState = newEvalState }, Cmd.none )
