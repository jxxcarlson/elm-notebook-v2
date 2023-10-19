module View.Popup.Packages exposing (..)

import Dict exposing (Dict)
import Element as E exposing (Element)
import Element.Background as Background
import Element.Border
import Element.Font as Font
import Message
import Notebook.Book
import Notebook.Eval
import Notebook.ThemedColor as ThemedColor
import Notebook.Types
import Types
import View.Button
import View.Geometry
import View.Input
import View.Style


view : Types.FrontendModel -> Element Types.FrontendMsg
view model =
    let
        viewData =
            { book = model.currentBook
            , kvDict = model.kvDict
            , width = View.Geometry.notebookWidth model
            , ticks = model.tickCount
            , cellDirection = model.cellInsertionDirection
            , errorOffset = Notebook.Eval.replErrorOffset model.evalState.decls
            , theme = model.theme
            , pressedKeys = model.pressedKeys
            }
    in
    case model.popupState of
        Types.PackageListPopup ->
            E.column
                [ E.spacing 18
                , View.Style.bgGray 0.4
                , E.padding 24
                , E.centerX
                , Element.Border.width 1
                , Element.Border.color (ThemedColor.themedPopupDividerColor viewData.theme)
                , Background.color (ThemedColor.themedPopupBackgroundColor viewData.theme)
                , Font.color (ThemedColor.themedValueTextColor viewData.theme)
                , E.moveUp (View.Geometry.appHeight model - 90 |> toFloat)
                ]
                [ E.row [ E.spacing 12 ]
                    [ E.el [ Font.bold, Font.size 14, Font.color (E.rgb 0.9 0.9 0.9) ] (E.text "Packages for this notebook")
                    , E.el [ Font.italic, Font.size 14, Font.color (E.rgb 0.9 0.9 0.9) ] (E.text "Add more packages below, one per line.")
                    ]
                , View.Input.submitPackageList model
                    [ Background.color (ThemedColor.themedCodeCellBackgroundColor viewData.theme)
                    , Font.color (ThemedColor.themedCodeCellTextColor viewData.theme)
                    , Element.Border.color (ThemedColor.themedPopupDividerColor viewData.theme)
                    ]
                    [ Font.color (E.rgb 0.9 0.9 0.9) ]
                , E.column
                    [ E.height (E.px 150)
                    , E.width (E.px 500)
                    , E.scrollbarY
                    , Font.color (ThemedColor.themedTextColor viewData.theme)
                    , Background.color (ThemedColor.themedCodeCellBackgroundColor viewData.theme)
                    , Element.Border.width 1
                    , Element.Border.color (ThemedColor.themedPopupDividerColor viewData.theme)
                    , E.spacing 12
                    , E.padding 24
                    ]
                    --(viewPackage model.packageDict)
                    (E.el [ Font.size 12, Font.bold ] (E.text "Installed packages (Elm compiler)")
                        :: List.map viewCompilerPackage model.packagesFromCompiler
                    )
                , E.row [ E.spacing 18 ]
                    [ View.Button.submitPackageList
                    , View.Button.dismissPopup
                    ]
                , E.el [ E.width E.fill, E.paddingXY 8 8, View.Style.bgGray 0 ] (Message.view 500 180 model)
                ]

        _ ->
            E.none


viewCompilerPackage : { name : String, version : String } -> Element Types.FrontendMsg
viewCompilerPackage package =
    E.row [ Font.size 12, E.spacing 14 ] [ E.el [ E.width (E.px 190) ] (E.text package.name), E.el [ E.width (E.px 60) ] (E.text package.version) ]


viewPackage : Notebook.Book.ViewData -> Dict String Notebook.Types.ElmPackageSummary -> List (Element Types.FrontendMsg)
viewPackage viewData dict =
    dict
        |> Dict.values
        |> List.map (viewValue viewData)


viewValue : Notebook.Book.ViewData -> Notebook.Types.ElmPackageSummary -> Element Types.FrontendMsg
viewValue viewData summary =
    E.row
        [ Font.size 14
        , E.width (E.px 500)
        , E.paddingXY 12 0
        , E.height (E.px 36)
        , Background.color (ThemedColor.themedBackgroundColor viewData.theme)

        --, Background.color (E.rgb 1.0 0.9 0.9)
        ]
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
