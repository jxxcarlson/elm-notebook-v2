module Notebook.EvalCell exposing
    ( booksToInclude
    , compileCellsCmd
    , executeCellCommand
    , executeNotebook
    , getCellsToInclude
    , isTypeDefOrDeclaration
    , processCell
    , updateEvalStateWithCells
    )

import Http
import Lamdera
import List.Extra
import Message
import Notebook.Book
import Notebook.Cell as Cell exposing (Cell, CellState(..), CellType(..), CellValue(..))
import Notebook.CellHelper
import Notebook.Eval as Eval
import Notebook.Parser
import Notebook.Types exposing (EvalState)
import Task exposing (Task)
import Types exposing (FrontendMsg)
import Util
import View.Config


type alias Model =
    Types.FrontendModel



-- EXECUTE NOTEBOOK


booksToInclude book =
    List.filter (\cell -> String.left 8 cell.text == "@include") book.cells
        |> List.map (.text >> String.dropLeft 8 >> String.trim)


getCellsToInclude : List String -> Cmd FrontendMsg
getCellsToInclude bookNames =
    Lamdera.sendToBackend (Types.GetCellsToInclude bookNames)


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
            updateEvalStateWithCells model.includedCells currentBook.cells Notebook.Types.emptyEvalState
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
    , compileCellsCmd newEvalState newBook.cells
    )


compileCellsCmd : EvalState -> List Cell -> Cmd FrontendMsg
compileCellsCmd evalState cells =
    let
        filteredCells =
            cells
                |> List.map removeCommentsFromCell
                |> List.filter passExpressionCellFilter
    in
    Task.attempt Types.ExecuteCells (compileJsForCells evalState filteredCells)


removeCommentsFromCell : Cell -> Cell
removeCommentsFromCell cell =
    { cell | text = removeComments cell.text }


removeComments : String -> String
removeComments str =
    let
        lines =
            String.lines str

        noComments =
            List.filter (\line -> String.left 2 line /= "--") lines
    in
    String.join "\n" noComments |> String.trim


passExpressionCellFilter : Cell -> Bool
passExpressionCellFilter cell =
    case cell.tipe of
        Cell.CTCode ->
            case Notebook.Parser.classify cell.text of
                Err _ ->
                    False

                Ok classif ->
                    case classif of
                        Notebook.Parser.Expr str ->
                            if str == "" then
                                False

                            else
                                True

                        _ ->
                            False

        Cell.CTMarkdown ->
            False


compileJsForCells : EvalState -> List Cell -> Task Http.Error (List ( Int, String ))
compileJsForCells evalState cells =
    let
        tasks =
            List.map (compileJs evalState) cells
    in
    Task.sequence tasks


compileJs : EvalState -> Cell -> Task Http.Error ( Int, String )
compileJs evalState cell =
    Task.andThen (\js -> Task.succeed ( cell.index, js )) (Eval.requestEvaluationAsTask evalState cell.text)


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


updateEvalStateWithCells : List Cell -> List Cell -> EvalState -> EvalState
updateEvalStateWithCells includedCells cells evalState =
    List.foldl updateEvalStateWithCell evalState (includedCells ++ cells)


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


isTypeDefOrDeclaration : Cell -> Bool
isTypeDefOrDeclaration cell =
    case cell.tipe of
        Cell.CTMarkdown ->
            False

        Cell.CTCode ->
            case Notebook.Parser.classify (compress cell.text) of
                Err _ ->
                    False

                Ok classif ->
                    case classif of
                        Notebook.Parser.Expr _ ->
                            False

                        Notebook.Parser.Decl _ _ ->
                            True

                        Notebook.Parser.ElmType _ _ ->
                            True

                        Notebook.Parser.TypeAlias _ _ ->
                            True

                        Notebook.Parser.Import _ _ ->
                            False


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
    let
        model =
            case cellState of
                CSEdit ->
                    model_

                CSEditCompact ->
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
                    processCode { model | currentCellIndex = model.currentCellIndex + 1 }
                        { cell
                            | report = ( cell.index, Nothing )
                            , replData = Nothing
                            , cellState = CSView
                            , highlightTime = View.Config.highlightTime
                        }

                Cell.CTMarkdown ->
                    processMarkdown { model | currentCellIndex = model.currentCellIndex + 1 } { cell | cellState = CSView }


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
            updateEvalStateWithCells model.includedCells model.currentBook.cells Notebook.Types.emptyEvalState
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
