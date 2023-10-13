module View.Popup.Packages exposing (..)

import Dict exposing (Dict)
import Element as E exposing (Element)
import Element.Background as Background
import Element.Font as Font
import Message
import Notebook.Types
import Types
import View.Button
import View.Geometry
import View.Input
import View.Style


view : Types.FrontendModel -> Element Types.FrontendMsg
view model =
    case model.popupState of
        Types.PackageListPopup ->
            E.column
                [ E.spacing 18
                , View.Style.bgGray 0.4
                , E.padding 24
                , E.centerX

                --, E.alignRight
                , E.moveUp (View.Geometry.appHeight model - 100 |> toFloat)
                ]
                [ View.Input.submitPackageList model
                , E.column
                    [ E.height (E.px 300)
                    , E.width (E.px 500)
                    , E.scrollbarY
                    , Background.color (E.rgb 1 1 1)
                    , E.spacing 12
                    , E.padding 24
                    ]
                    --(viewPackage model.packageDict)
                    (E.el [ Font.size 12, Font.bold ] (E.text "Installed packages (Elm compiler)") :: List.map viewCompilerPackage model.packagesFromCompiler)
                , E.row [ E.spacing 18 ]
                    [ View.Button.submitPackageList

                    --  , View.Button.submitTest
                    , View.Button.dismissPopup
                    ]
                , E.el [ E.width E.fill, E.paddingXY 8 8, View.Style.bgGray 0 ] (Message.viewSmall 250 model)
                ]

        _ ->
            E.none


viewCompilerPackage : { name : String, version : String } -> Element Types.FrontendMsg
viewCompilerPackage package =
    E.row [ Font.size 12, E.spacing 14 ] [ E.el [ E.width (E.px 190) ] (E.text package.name), E.el [ E.width (E.px 60) ] (E.text package.version) ]


viewPackage : Dict String Notebook.Types.ElmPackageSummary -> List (Element Types.FrontendMsg)
viewPackage dict =
    dict
        |> Dict.values
        |> List.map viewValue


viewValue : Notebook.Types.ElmPackageSummary -> Element Types.FrontendMsg
viewValue summary =
    E.row [ Font.size 14, E.width (E.px 500), E.paddingXY 12 0, E.height (E.px 36), Background.color (E.rgb 1.0 0.9 0.9) ]
        [ E.row [ E.width (E.px 180), E.scrollbarX ] [ E.text summary.name ]
        , E.row [ E.width (E.px 40) ] [ E.text summary.version ]
        , E.row [ E.width (E.px 220), E.scrollbarX, E.spacing 12 ] (List.map (\x -> E.el [ E.width E.fill ] (E.text x)) summary.exposedModules)
        ]


padLeft k =
    E.paddingEach { left = k, right = 0, top = 0, bottom = 0 }



--type alias ElmPackageSummary =
--    { dependencies : Dict String String
--    , exposedModules : List String
--    , name : String
--    , version : String
--    }
