module Frontend.UIHelper exposing
    ( handleKeyPresses
    , handlePopups
    , handleViewport
    )

import Browser.Dom
import Keyboard
import Lamdera
import Notebook.Cell
import Notebook.CellHelper
import Notebook.EvalCell
import Notebook.Package
import Types exposing (PopupState(..))


type alias Model =
    Types.FrontendModel


type alias Msg =
    Types.FrontendMsg


handleKeyPresses model keyMsg =
    let
        pressedKeys : List Keyboard.Key
        pressedKeys =
            Keyboard.update keyMsg model.pressedKeys

        ( newModel, cmd ) =
            if List.member Keyboard.Control pressedKeys && List.member Keyboard.Enter pressedKeys then
                Notebook.EvalCell.processCell Notebook.Cell.CSEdit
                    model.currentCellIndex
                    { model | pressedKeys = pressedKeys, errorReports = [] }

            else
                ( { model | pressedKeys = pressedKeys }, Cmd.none )
    in
    ( newModel, cmd )


handlePopups : Model -> PopupState -> ( Model, Cmd Msg )
handlePopups model popupState =
    case popupState of
        NoPopup ->
            ( { model | popupState = NoPopup }, Cmd.none )

        EditDataSetPopup metaData ->
            ( { model
                | popupState = EditDataSetPopup metaData
                , inputName = metaData.name
                , inputDescription = metaData.description
                , inputComments = metaData.comments
              }
            , Cmd.none
            )

        NewNotebookPopup ->
            if model.popupState == NewNotebookPopup then
                ( { model | popupState = NoPopup }, Cmd.none )

            else
                ( { model | popupState = NewNotebookPopup }, Cmd.none )

        CLIPopup ->
            if model.popupState == CLIPopup then
                ( { model | popupState = NoPopup }, Cmd.none )

            else
                ( { model | popupState = CLIPopup }, Cmd.none )

        PackageListPopup ->
            if model.popupState == PackageListPopup then
                ( { model | popupState = NoPopup }, Cmd.none )

            else
                let
                    packagesString =
                        (model.currentBook.packageNames |> String.join "\n") ++ "\n"

                    inputPackages =
                        packagesString
                in
                ( { model
                    | popupState = PackageListPopup
                    , inputPackages =
                        packagesString
                  }
                , Notebook.Package.requestPackagesFromCompiler
                )

        StateEditorPopup ->
            if model.popupState == StateEditorPopup then
                ( { model | popupState = NoPopup }, Cmd.none )

            else
                ( { model
                    | popupState = StateEditorPopup
                  }
                , Cmd.none
                )

        ManualPopup ->
            if model.popupState == ManualPopup then
                ( { model | popupState = NoPopup }, Cmd.none )

            else
                ( { model | popupState = ManualPopup }, Cmd.none )

        ViewPublicDataSetsPopup ->
            if model.popupState == ViewPublicDataSetsPopup then
                ( { model | popupState = NoPopup }, Cmd.none )

            else
                ( { model | popupState = ViewPublicDataSetsPopup }, Cmd.none )

        ViewPrivateDataSetsPopup ->
            if model.popupState == ViewPrivateDataSetsPopup then
                ( { model | popupState = NoPopup }, Cmd.none )

            else
                ( { model | popupState = ViewPrivateDataSetsPopup }, Cmd.none )

        NewDataSetPopup ->
            if model.popupState == NewDataSetPopup then
                ( { model | popupState = NoPopup }, Cmd.none )

            else
                ( { model | popupState = NewDataSetPopup }, Cmd.none )

        SignUpPopup ->
            if model.popupState == SignUpPopup then
                ( { model | popupState = NoPopup }, Cmd.none )

            else
                ( { model
                    | popupState = SignUpPopup
                    , inputUsername = ""
                    , inputEmail = ""
                    , inputPassword = ""
                    , inputPasswordAgain = ""
                  }
                , Cmd.none
                )

        AdminPopup ->
            if model.popupState == AdminPopup then
                ( { model | popupState = NoPopup }, Cmd.none )

            else
                ( { model | popupState = AdminPopup }, Lamdera.sendToBackend Types.SendUsers )


handleViewport : Model -> Browser.Dom.Viewport -> ( Model, Cmd Msg )
handleViewport model vp =
    case model.appState of
        Types.Loaded ->
            updateWithViewport vp model

        Types.Loading ->
            let
                -- First we have to get the window width and height
                w =
                    round vp.viewport.width

                h =
                    round vp.viewport.height
            in
            -- Then we set the appState to Loaded
            ( { model
                | windowWidth = w
                , windowHeight = h
                , appState = Types.Loaded
              }
            , Cmd.none
            )


updateWithViewport : Browser.Dom.Viewport -> Model -> ( Model, Cmd Msg )
updateWithViewport vp model =
    let
        w =
            round vp.viewport.width

        h =
            round vp.viewport.height
    in
    ( { model
        | windowWidth = w
        , windowHeight = h
      }
    , Cmd.none
    )
