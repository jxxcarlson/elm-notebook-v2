module View.LHSidebar exposing (..)

import Dict exposing (Dict)
import Element as E exposing (Element)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Notebook.Book exposing (Book)
import Notebook.Cell exposing (Cell)
import Notebook.ErrorReporter exposing (RenderedErrorReport)
import Notebook.Eval
import Notebook.Types exposing (ErrorReport, MessageItem(..))
import Notebook.View
import Predicate
import Types exposing (FrontendModel, FrontendMsg)
import UILibrary.Color as Color
import User
import Util
import View.Button as Button
import View.Color
import View.Config
import View.Geometry
import View.Style
import View.Utility


view : FrontendModel -> Element FrontendMsg
view model =
    E.column
        [ E.height (E.px (View.Geometry.bodyHeight model))
        , Font.color (E.rgb 0.9 0.9 0.9)
        , Background.color (E.rgb 0.5 0.5 0.6)
        , E.paddingXY 8 12
        , E.spacing 12
        , E.width (E.px View.Config.lhSidebarWidth)
        , E.width E.fill
        , Background.color View.Color.rhSidebarColor
        , Font.size 12
        ]
        [ Button.importNotebook
        , Button.exportNotebook
        , Button.cliPopup model
        ]
        |> View.Utility.showIf (Predicate.regularUser model)
