module Notebook.EvalCell exposing (processCell, updateDeclarationsDictionary)

import Dict
import Keyboard
import List.Extra
import Notebook.Book
import Notebook.Cell as Cell exposing (Cell, CellState(..), CellType(..), CellValue(..))
import Notebook.CellHelper
import Notebook.Eval as Eval
import Notebook.Parser
import Notebook.Types exposing (EvalState)
import Types exposing (FrontendMsg)


type alias Model =
    Types.FrontendModel


updateDeclarationsDictionary : Model -> ( Model, Cmd FrontendMsg )
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

        ( newModel, commands ) =
            List.foldl folder ( { model | evalState = newEvalState }, [] ) indices
    in
    ( newModel, Cmd.batch commands )


folder : Int -> ( Model, List (Cmd FrontendMsg) ) -> ( Model, List (Cmd FrontendMsg) )
folder k ( model, cmds ) =
    let
        ( model_, cmd ) =
            processCell_ k model
    in
    ( model_, cmd :: cmds )


processCell_ : Int -> Model -> ( Model, Cmd FrontendMsg )
processCell_ cellIndex model =
    processCell CSView cellIndex model


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
                    processCode model cell

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


ppp =
    { decls =
        Dict.fromList
            [ ( "inc x", "inc x  =  x + 1\n" )
            , ( "numbers", "numbers  =  List.range 1 20\n" )
            ]
    , imports = Dict.fromList []
    , types = Dict.fromList []
    }
