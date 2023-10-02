module Backend.Data exposing (createDataSet, getListOfDataSets, saveDataSet)

import Backend.Utility
import Dict
import Lamdera
import Notebook.DataSet
import Types exposing (BackendModel)


createDataSet model clientId dataSet_ =
    let
        identifier =
            Backend.Utility.getUniqueIdentifier dataSet_.identifier model.dataSetLibrary

        dataSet =
            { dataSet_
                | createdAt = model.currentTime
                , modifiedAt = model.currentTime
                , identifier = identifier
            }

        dataSetLibrary =
            Dict.insert identifier dataSet model.dataSetLibrary
    in
    ( { model | dataSetLibrary = dataSetLibrary }
    , Lamdera.sendToFrontend clientId (Types.SendMessage <| "Data set " ++ dataSet.name ++ " added with identifier = " ++ identifier)
    )


saveDataSet model clientId dataSetMetaData =
    case Dict.get dataSetMetaData.identifier model.dataSetLibrary of
        Nothing ->
            ( model, Lamdera.sendToFrontend clientId (Types.SendMessage <| "Could not save data set " ++ dataSetMetaData.name) )

        Just dataSet ->
            let
                newDataSet =
                    { dataSet
                        | modifiedAt = model.currentTime
                        , name = dataSetMetaData.name
                        , description = dataSetMetaData.description
                        , public = dataSetMetaData.public
                    }

                dataSetLibrary =
                    Dict.insert dataSetMetaData.identifier newDataSet model.dataSetLibrary
            in
            ( { model | dataSetLibrary = dataSetLibrary }
            , Lamdera.sendToFrontend clientId (Types.SendMessage <| "Data set " ++ dataSet.name ++ " saved")
            )


getListOfDataSets : Lamdera.ClientId -> BackendModel -> Types.DataSetDescription -> Cmd backendMsg
getListOfDataSets clientId model description =
    case description of
        Types.PublicDatasets ->
            let
                publicDataSets : List Notebook.DataSet.DataSetMetaData
                publicDataSets =
                    List.filter (\dataSet -> dataSet.public) (Dict.values model.dataSetLibrary)
                        |> List.map Notebook.DataSet.extractMetaData
            in
            Lamdera.sendToFrontend clientId (Types.GotListOfPublicDataSets publicDataSets)

        Types.UserDatasets username ->
            let
                userDatasets =
                    List.filter (\dataSet -> dataSet.author == username) (Dict.values model.dataSetLibrary)
                        |> List.map Notebook.DataSet.extractMetaData
            in
            Lamdera.sendToFrontend clientId (Types.GotListOfPrivateDataSets userDatasets)
