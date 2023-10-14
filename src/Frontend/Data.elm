module Frontend.Data exposing (askToCreateDataSet, askToDeleteDataSet, askToSaveDataSet)

import Lamdera
import List.Extra
import Notebook.DataSet
import Time
import Types exposing (FrontendModel, FrontendMsg(..), ToBackend(..))


type alias Model =
    FrontendModel


type alias Msg =
    FrontendMsg


askToCreateDataSet : Model -> ( Model, Cmd Msg )
askToCreateDataSet model =
    case model.currentUser of
        Nothing ->
            ( model, Cmd.none )

        Just user ->
            let
                newDataset =
                    Notebook.DataSet.makeDataSet model user

                myDataSetMeta =
                    Notebook.DataSet.extractMetaData newDataset

                privateDataSetMetaDataList =
                    myDataSetMeta :: model.privateDataSetMetaDataList
            in
            ( { model
                | popupState = Types.NoPopup
                , privateDataSetMetaDataList = privateDataSetMetaDataList
              }
            , Lamdera.sendToBackend (CreateDataSet newDataset)
            )


askToSaveDataSet : Model -> { author : String, name : String, identifier : String, public : Bool, createdAt : Time.Posix, modifiedAt : Time.Posix, description : String, comments : String } -> ( Model, Cmd Msg )
askToSaveDataSet model dataSetMetaData =
    let
        metaData : Notebook.DataSet.DataSetMetaData
        metaData =
            { dataSetMetaData | name = model.inputName, description = model.inputDescription, comments = model.inputComments }
    in
    ( { model
        | popupState = Types.NoPopup
        , publicDataSetMetaDataList =
            if metaData.public && not (List.member metaData model.publicDataSetMetaDataList) then
                metaData :: model.publicDataSetMetaDataList

            else if metaData.public then
                List.Extra.setIf (\d -> d.identifier == metaData.identifier) metaData model.publicDataSetMetaDataList

            else
                List.filter (\d -> d.identifier /= metaData.identifier) model.publicDataSetMetaDataList
        , privateDataSetMetaDataList = List.Extra.setIf (\d -> d.identifier == metaData.identifier) metaData model.privateDataSetMetaDataList
      }
    , Lamdera.sendToBackend (SaveDataSet metaData)
    )


askToDeleteDataSet : Model -> { author : String, name : String, identifier : String, public : Bool, createdAt : Time.Posix, modifiedAt : Time.Posix, description : String, comments : String } -> ( Model, Cmd Msg )
askToDeleteDataSet model dataSetMetaData =
    let
        publicDataSetMetaDataList =
            List.filter (\d -> d.identifier /= dataSetMetaData.identifier) model.publicDataSetMetaDataList

        privateDataSetMetaDataList =
            List.filter (\d -> d.identifier /= dataSetMetaData.identifier) model.privateDataSetMetaDataList
    in
    ( { model
        | popupState = Types.NoPopup
        , publicDataSetMetaDataList = publicDataSetMetaDataList
        , privateDataSetMetaDataList = privateDataSetMetaDataList
      }
    , Lamdera.sendToBackend (DeleteDataSet dataSetMetaData)
    )
