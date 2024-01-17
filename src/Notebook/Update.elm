module Notebook.Update exposing
    ( clearCell
    , clearNotebookValues
    , deleteCell
    , editCell
    , makeNewCell
    , setCellValue
    , toggleCellLock
    , toggleComment
    , updateCellText
    )

{-|

    This module implements functions called by Frontend.update
    (see the list of functions exposed).

    All return either (a) (FrontendModel, Cmd FrontendMsg) or
    (b) Cmd FrontendMsg

    See the value 'commands' for the complete list of commands.

New commands are implemented in the case statement
of function 'executeCell'. A command will be
executed only if it also appears in the list 'commands'.

-}

--import Notebook.Types
--    exposing
--        ( Book
--        , Cell
--        , CellState(..)
--        , CellValue(..)
--        , VisualType(..)
--        )

import Dict
import Lamdera
import List.Extra
import Notebook.Book exposing (Book)
import Notebook.Cell exposing (Cell, CellState(..), CellType(..), CellValue(..))
import Notebook.CellHelper
import Notebook.Types
import Types exposing (FrontendModel, FrontendMsg(..))


clearNotebookValues : Book -> FrontendModel -> ( FrontendModel, Cmd FrontendMsg )
clearNotebookValues book model =
    let
        newBook =
            { book
                | cells =
                    List.map
                        (\cell ->
                            { cell
                                | value = CVNone
                                , cellState = CSView
                                , report = ( cell.index, Nothing )
                                , replData = Nothing
                            }
                        )
                        book.cells
            }
    in
    ( { model
        | errorReports = []
        , evalState = Notebook.Types.emptyEvalState
        , currentBook = newBook
        , packageDict = Dict.empty
      }
    , Lamdera.sendToBackend (Types.SaveNotebook newBook)
    )



-- OTHER TOP LEVEL FUNCTIONS


deleteCell : Int -> FrontendModel -> FrontendModel
deleteCell index model =
    case List.Extra.getAt index model.currentBook.cells of
        Nothing ->
            model

        Just _ ->
            let
                prefix =
                    List.filter (\cell -> cell.index < index) model.currentBook.cells
                        |> List.map (\cell -> { cell | cellState = CSView })

                suffix =
                    List.filter (\cell -> cell.index > index) model.currentBook.cells
                        |> List.map (\cell -> { cell | cellState = CSView, index = cell.index - 1 })

                oldBook =
                    model.currentBook

                newBook =
                    { oldBook | cells = prefix ++ suffix, dirty = True }
            in
            { model | currentCellIndex = 0, currentBook = newBook }


editCell : FrontendModel -> Cell -> ( FrontendModel, Cmd FrontendMsg )
editCell model cell =
    let
        updatedCell =
            { cell | cellState = CSEdit }

        newBook =
            Notebook.CellHelper.updateBookWithCell updatedCell model.currentBook
    in
    ( { model | currentCell = Just updatedCell, currentCellIndex = cell.index, cellContent = cell.text, currentBook = newBook }, Cmd.none )


clearCell : FrontendModel -> Int -> ( FrontendModel, Cmd FrontendMsg )
clearCell model index =
    case List.Extra.getAt index model.currentBook.cells of
        Nothing ->
            ( model, Cmd.none )

        Just cell_ ->
            let
                updatedCell =
                    { cell_ | cellState = CSView, value = CVNone, replData = Nothing }

                newBook =
                    Notebook.CellHelper.updateBookWithCell updatedCell model.currentBook
            in
            ( { model
                | cellContent = ""
                , currentBook = newBook
              }
            , Cmd.none
            )


makeNewCell : FrontendModel -> CellState -> CellType -> Int -> ( FrontendModel, Cmd FrontendMsg )
makeNewCell model cellState cellType index =
    let
        newCell =
            { index =
                case model.cellInsertionDirection of
                    Notebook.Types.Down ->
                        index + 1

                    Notebook.Types.Up ->
                        index
            , text = "# New cell (" ++ String.fromInt (index + 2) ++ ") "
            , value = CVNone
            , tipe = cellType
            , cellState = cellState
            , commented = False
            , locked = False
            , report = ( 0, Nothing )
            , replData = Nothing
            , highlightTime = 0
            }

        newBook =
            Notebook.CellHelper.addCellToBook newCell (Notebook.Book.initializeCellState model.currentBook)

        _ =
            List.length newBook.cells
    in
    ( { model
        | cellContent = ""
        , currentBook = newBook
        , currentCellIndex = index + 1
      }
    , Cmd.none
    )


setCellValue : FrontendModel -> Int -> CellValue -> FrontendModel
setCellValue model index cellValue =
    case List.Extra.getAt index model.currentBook.cells of
        Nothing ->
            model

        Just cell_ ->
            { model | currentBook = Notebook.CellHelper.updateBookWithCell { cell_ | value = cellValue } model.currentBook }


updateCellText : FrontendModel -> Int -> String -> FrontendModel
updateCellText model index str =
    case List.Extra.getAt index model.currentBook.cells of
        Nothing ->
            model

        Just cell_ ->
            let
                updatedCell =
                    { cell_ | text = str }
            in
            { model | cellContent = str, currentBook = Notebook.CellHelper.updateBookWithCell updatedCell model.currentBook }


toggleCellLock : Cell -> FrontendModel -> FrontendModel
toggleCellLock cell model =
    let
        updatedCell =
            { cell | locked = not cell.locked }

        updatedBook =
            Notebook.CellHelper.updateBookWithCell updatedCell model.currentBook
    in
    { model | currentBook = updatedBook }


toggleComment model commented index =
    case List.Extra.getAt index model.currentBook.cells of
        Nothing ->
            ( model, Cmd.none )

        Just cell ->
            let
                book =
                    model.currentBook

                newCell =
                    if commented then
                        Notebook.Cell.uncomment cell

                    else
                        Notebook.Cell.comment { cell | cellState = CSView }

                newBook_ =
                    Notebook.Book.replaceCell newCell book
            in
            ( { model
                | currentBook = newBook_
                , currentCell = Just newCell
                , cellContent = newCell.text
              }
            , Lamdera.sendToBackend (Types.SaveNotebook newBook_)
            )
