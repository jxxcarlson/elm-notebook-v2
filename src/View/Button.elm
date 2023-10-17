module View.Button exposing
    ( adminPopup
    , cancelDeleteNotebook
    , clearValues
    , cloneNotebook
    , createDataSet
    , deleteDataSet
    , deleteNotebook
    , dismissPopup
    , dismissPopupSmall
    , editDataSet
    , editTitle
    , executeNotebook
    , exportNotebook
    , getPackagesFromCompiler
    , getRandomProbabilities
    , importNotebook
    , lockCell
    , manual
    , manualLarge
    , myNotebooks
    , newDataSet
    , newNotebook
    , packagesPopup
    , public
    , publicNotebooks
    , pullNotebook
    , resetClock
    , runCell
    , runTask
    , saveDataSetAsPrivate
    , saveDataSetAsPublic
    , sendProgramToBeCompiled
    , setClock
    , setUpUser
    , signIn
    , signOut
    , signUp
    , stateEditor
    , submitPackageList
    , submitTest
    , toggleTheme
    , toggleViewPrivateDataSets
    , toggleViewPublicDataSets
    , updateDeclarationsDictionary
    , viewNotebookEntry
    )

import Config
import Element as E exposing (Element)
import Element.Background as Background
import Element.Font as Font
import Element.Input as Input
import Notebook.Book exposing (Book)
import Notebook.Cell exposing (CellState(..), CellType)
import Notebook.DataSet
import Types
    exposing
        ( ClockState(..)
        , DeleteNotebookState(..)
        , FrontendModel
        , FrontendMsg(..)
        , PopupState(..)
        , ShowNotebooks(..)
        )
import UILibrary.Button as Button
import UILibrary.Color as Color
import View.Style



-- TEMPLATES


buttonTemplate : List (E.Attribute msg) -> msg -> String -> Element msg
buttonTemplate attrList msg label_ =
    E.row ([ View.Style.bgGray 0.2, E.pointer, E.mouseDown [ Background.color Color.darkRed ] ] ++ attrList)
        [ Input.button View.Style.buttonStyle
            { onPress = Just msg
            , label = E.el [ E.centerX, E.centerY, Font.size 14 ] (E.text label_)
            }
        ]


linkTemplate : msg -> E.Color -> String -> Element msg
linkTemplate msg fontColor label_ =
    E.row [ E.pointer, E.mouseDown [ Background.color Color.paleBlue ] ]
        [ Input.button linkStyle
            { onPress = Just msg
            , label = E.el [ E.centerX, E.centerY, Font.size 14, Font.color fontColor ] (E.text label_)
            }
        ]


linkStyle =
    [ Font.color (E.rgb255 255 255 255)
    , E.paddingXY 8 2
    ]



-- CELL
-- POPUP


dismissPopupTransparent : Element FrontendMsg
dismissPopupTransparent =
    Button.largePrimary { msg = ChangePopup Types.NoPopup, status = Button.ActiveTransparent, label = Button.Text "x", tooltipText = Nothing }


dismissPopupSmall : Element FrontendMsg
dismissPopupSmall =
    Button.smallPrimary { msg = ChangePopup NoPopup, status = Button.ActiveTransparent, label = Button.Text "x", tooltipText = Nothing }


executeNotebook : Element FrontendMsg
executeNotebook =
    Button.smallPrimary { msg = ExecuteNotebook, status = Button.Highlighted, label = Button.Text "Run all cells", tooltipText = Nothing }


clearNotebookValues : Element FrontendMsg
clearNotebookValues =
    Button.smallPrimary { msg = ClearNotebookValues, status = Button.Highlighted, label = Button.Text "Clear cell values", tooltipText = Nothing }


updateDeclarationsDictionary : Element FrontendMsg
updateDeclarationsDictionary =
    Button.smallPrimary { msg = UpdateDeclarationsDictionary, status = Button.Active, label = Button.Text "Update", tooltipText = Nothing }


getPackagesFromCompiler : Element FrontendMsg
getPackagesFromCompiler =
    Button.smallPrimary { msg = GetPackagesFromCompiler, status = Button.Active, label = Button.Text "Get packages from compiler", tooltipText = Nothing }


runCell : CellState -> CellType -> Int -> Element FrontendMsg
runCell cellState cellType index =
    -- TODO
    case cellType of
        Notebook.Cell.CTCode ->
            let
                label =
                    case cellState of
                        CSView ->
                            "Run!"

                        CSEdit ->
                            "Run"
            in
            Button.smallPrimary { msg = EvalCell cellState index, status = Button.Active, label = Button.Text label, tooltipText = Just "ctrl-Enter" }

        Notebook.Cell.CTMarkdown ->
            case cellState of
                CSView ->
                    E.none

                CSEdit ->
                    Button.smallPrimary { msg = EvalCell CSView index, status = Button.Active, label = Button.Text "Close", tooltipText = Just "ctrl-Enter" }


dismissPopup : Element FrontendMsg
dismissPopup =
    Button.largePrimary { msg = ChangePopup NoPopup, status = Button.Active, label = Button.Text "x", tooltipText = Nothing }


sendProgramToBeCompiled : Element FrontendMsg
sendProgramToBeCompiled =
    Button.largePrimary { msg = SendProgramToBeCompiled, status = Button.Active, label = Button.Text "Compile Test Program", tooltipText = Nothing }


editTitle : Types.AppMode -> Element FrontendMsg
editTitle mode =
    if mode == Types.AMEditTitle then
        Button.smallPrimary { msg = UpdateNotebookTitle, status = Button.Active, label = Button.Text "Save Notebook", tooltipText = Nothing }

    else
        Button.smallPrimary { msg = ChangeAppMode Types.AMEditTitle, status = Button.Active, label = Button.Text "Edit Title", tooltipText = Nothing }


getRandomProbabilities : Element FrontendMsg
getRandomProbabilities =
    Button.smallPrimary { msg = GetRandomProbabilities 3, status = Button.Active, label = Button.Text "Get Random Probabilities", tooltipText = Nothing }


setClock : FrontendModel -> Element FrontendMsg
setClock model =
    case model.clockState of
        ClockRunning ->
            Button.smallPrimary { msg = SetClock ClockPaused, status = Button.ActiveRunning, label = Button.Text "Clock Running", tooltipText = Nothing }

        ClockPaused ->
            Button.smallPrimary { msg = SetClock ClockRunning, status = Button.ActiveSpecial, label = Button.Text "Clock Paused", tooltipText = Nothing }

        ClockStopped ->
            Button.smallPrimary { msg = SetClock ClockRunning, status = Button.Highlighted, label = Button.Text "Clock Stopped", tooltipText = Nothing }


resetClock : Element FrontendMsg
resetClock =
    Button.smallPrimary { msg = Reset, status = Button.Active, label = Button.Text "Reset", tooltipText = Nothing }


clearValues : Element FrontendMsg
clearValues =
    Button.smallPrimary { msg = ClearNotebookValues, status = Button.Active, label = Button.Text "Clear Values", tooltipText = Nothing }


myNotebooks : Types.ShowNotebooks -> Element FrontendMsg
myNotebooks showNotebooks =
    case showNotebooks of
        ShowUserNotebooks ->
            Button.smallPrimary { msg = NoOpFrontendMsg, status = Button.Highlighted, label = Button.Text "My docs", tooltipText = Nothing }

        ShowPublicNotebooks ->
            Button.smallPrimary { msg = SetShowNotebooksState Types.ShowUserNotebooks, status = Button.Active, label = Button.Text "My docs", tooltipText = Nothing }


publicNotebooks : Types.ShowNotebooks -> Element FrontendMsg
publicNotebooks showNotebooks =
    case showNotebooks of
        ShowUserNotebooks ->
            Button.smallPrimary { msg = SetShowNotebooksState Types.ShowPublicNotebooks, status = Button.Active, label = Button.Text "Public docs", tooltipText = Nothing }

        ShowPublicNotebooks ->
            Button.smallPrimary { msg = NoOpFrontendMsg, status = Button.Highlighted, label = Button.Text "Public docs", tooltipText = Nothing }


cancelDeleteNotebook : DeleteNotebookState -> Element FrontendMsg
cancelDeleteNotebook deleteNotebookState =
    case deleteNotebookState of
        CanDeleteNotebook ->
            Button.smallPrimary { msg = CancelDeleteNotebook, status = Button.Highlighted, label = Button.Text "Cancel", tooltipText = Nothing }

        WaitingToDeleteNotebook ->
            E.none


deleteNotebook : DeleteNotebookState -> Element FrontendMsg
deleteNotebook deleteNotebookState =
    case deleteNotebookState of
        WaitingToDeleteNotebook ->
            Button.smallPrimary { msg = ProposeDeletingNotebook, status = Button.Active, label = Button.Text "Delete Notebook", tooltipText = Nothing }

        CanDeleteNotebook ->
            Button.smallPrimary { msg = ProposeDeletingNotebook, status = Button.Highlighted, label = Button.Text "Delete Notebook", tooltipText = Nothing }


public : Book -> Element FrontendMsg
public book =
    if book.public then
        Button.smallPrimary { msg = TogglePublic, status = Button.Active, label = Button.Text "Public", tooltipText = Nothing }

    else
        Button.smallPrimary { msg = TogglePublic, status = Button.Active, label = Button.Text "Private", tooltipText = Nothing }


viewNotebookEntry : Book -> Book -> Element FrontendMsg
viewNotebookEntry currentBook book =
    if currentBook.id == book.id then
        if book.public then
            Button.smallPrimary { msg = NoOpFrontendMsg, status = Button.ActiveRunningSpecial, label = Button.Text book.title, tooltipText = Nothing }

        else
            Button.smallPrimary { msg = NoOpFrontendMsg, status = Button.ActiveRunning, label = Button.Text book.title, tooltipText = Nothing }

    else if book.public then
        Button.smallPrimary { msg = SetCurrentNotebook book, status = Button.ActiveTransparentSpecial, label = Button.Text book.title, tooltipText = Nothing }

    else
        Button.smallPrimary { msg = SetCurrentNotebook book, status = Button.ActiveTransparent, label = Button.Text book.title, tooltipText = Nothing }



--type Status
--    = Active
--    | Inactive
--    | Waiting
--    | Highlighted
--    | ActiveRunning
--    | ActiveRunningSpecial
--    | ActiveSpecial
--    | ActiveTransparentSpecial
--    | ActiveTransparent


cloneNotebook : Element FrontendMsg
cloneNotebook =
    Button.smallPrimary { msg = CloneNotebook, status = Button.Active, label = Button.Text "Clone", tooltipText = Nothing }


pullNotebook : Element FrontendMsg
pullNotebook =
    Button.smallPrimary { msg = PullNotebook, status = Button.Active, label = Button.Text "Update", tooltipText = Nothing }


exportNotebook : Element FrontendMsg
exportNotebook =
    Button.smallPrimary { msg = ExportNotebook, status = Button.Active, label = Button.Text "Export", tooltipText = Nothing }


importNotebook : Element FrontendMsg
importNotebook =
    Button.smallPrimary { msg = ImportRequested, status = Button.Active, label = Button.Text "Import", tooltipText = Nothing }


stateEditor : Element FrontendMsg
stateEditor =
    Button.smallPrimary { msg = ChangePopup StateEditorPopup, status = Button.Active, label = Button.Text "Edit", tooltipText = Nothing }


manual : Element FrontendMsg
manual =
    Button.smallPrimary { msg = ChangePopup ManualPopup, status = Button.Active, label = Button.Text "Manual", tooltipText = Nothing }


manualLarge : Element FrontendMsg
manualLarge =
    Button.largePrimary { msg = ChangePopup ManualPopup, status = Button.Active, label = Button.Text "Manual", tooltipText = Nothing }


newDataSet : Element FrontendMsg
newDataSet =
    Button.largePrimary { msg = ChangePopup NewDataSetPopup, status = Button.Active, label = Button.Text "New Data Set", tooltipText = Nothing }


editDataSet : Notebook.DataSet.DataSetMetaData -> Element FrontendMsg
editDataSet dataSetDescripion =
    Button.smallPrimary { msg = ChangePopup (EditDataSetPopup dataSetDescripion), status = Button.Active, label = Button.Text "Edit", tooltipText = Nothing }


lockCell : Notebook.Cell.Cell -> Element FrontendMsg
lockCell cell =
    case cell.locked of
        True ->
            Button.smallPrimary { msg = ToggleCellLock cell, status = Button.ActiveRunningSpecial, label = Button.Text "Locked", tooltipText = Just "Cell can't be edited when locked" }

        False ->
            Button.smallPrimary { msg = ToggleCellLock cell, status = Button.ActiveRunningSpecial, label = Button.Text "Unlocked", tooltipText = Just "Lock to prevent editing" }


saveDataSetAsPublic : Notebook.DataSet.DataSetMetaData -> Element FrontendMsg
saveDataSetAsPublic dataSetMeta =
    Button.largePrimary { msg = AskToSaveDataSet { dataSetMeta | public = True }, status = Button.Active, label = Button.Text "Save as public", tooltipText = Nothing }


saveDataSetAsPrivate : Notebook.DataSet.DataSetMetaData -> Element FrontendMsg
saveDataSetAsPrivate dataSetMeta =
    Button.largePrimary { msg = AskToSaveDataSet { dataSetMeta | public = False }, status = Button.Active, label = Button.Text "Save as private", tooltipText = Nothing }


deleteDataSet : Notebook.DataSet.DataSetMetaData -> Element FrontendMsg
deleteDataSet dataSetMeta =
    Button.largePrimary { msg = AskToDeleteDataSet dataSetMeta, status = Button.Active, label = Button.Text "Delete", tooltipText = Nothing }


createDataSet : Element FrontendMsg
createDataSet =
    Button.largePrimary { msg = AskToCreateDataSet, status = Button.Active, label = Button.Text "Create", tooltipText = Nothing }


toggleViewPublicDataSets : Element FrontendMsg
toggleViewPublicDataSets =
    Button.largePrimary { msg = ChangePopup ViewPublicDataSetsPopup, status = Button.Active, label = Button.Text "Public Datasets", tooltipText = Nothing }


toggleViewPrivateDataSets : Element FrontendMsg
toggleViewPrivateDataSets =
    Button.largePrimary { msg = ChangePopup ViewPrivateDataSetsPopup, status = Button.Active, label = Button.Text "My Datasets", tooltipText = Nothing }


newNotebook : Element FrontendMsg
newNotebook =
    Button.smallPrimary { msg = NewNotebook, status = Button.Active, label = Button.Text "New Notebook", tooltipText = Nothing }


toggleTheme : Notebook.Book.Theme -> Element FrontendMsg
toggleTheme theme =
    case theme of
        Notebook.Book.LightTheme ->
            Button.smallPrimary { msg = ToggleTheme theme, status = Button.Active, label = Button.Text "Light", tooltipText = Nothing }

        Notebook.Book.DarkTheme ->
            Button.smallPrimary { msg = ToggleTheme theme, status = Button.Active, label = Button.Text "Dark", tooltipText = Nothing }



-- USER


signOut username =
    buttonTemplate [] SignOut ("Sign out " ++ username)


signIn : Element FrontendMsg
signIn =
    buttonTemplate [] SignIn "Sign in"


signUp : Element FrontendMsg
signUp =
    buttonTemplate [] (ChangePopup SignUpPopup) "Sign up"


setUpUser : Element FrontendMsg
setUpUser =
    buttonTemplate [] SignUp "Submit"


submitPackageList : Element FrontendMsg
submitPackageList =
    buttonTemplate [] SubmitPackageList "Submit"


submitTest : Element FrontendMsg
submitTest =
    buttonTemplate [] SubmitTest "Test"



-- ADMIN


adminPopup : FrontendModel -> Element FrontendMsg
adminPopup model =
    buttonTemplate [] (ChangePopup AdminPopup) "Admin"


packagesPopup : FrontendModel -> Element FrontendMsg
packagesPopup model =
    buttonTemplate [] (ChangePopup PackageListPopup) "Install Packages"


runTask : Element FrontendMsg
runTask =
    buttonTemplate [] AdminRunTask "RBT"
