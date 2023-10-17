module Notebook.ThemedColor exposing (..)

import Element as E exposing (Element)
import Element.Background
import Notebook.Book exposing (ViewData)
import Notebook.Cell exposing (Cell, CellState(..), CellType(..), CellValue(..))
import Notebook.Config


themedPopupBackgroundColor : Notebook.Book.Theme -> E.Color
themedPopupBackgroundColor theme =
    case theme of
        Notebook.Book.LightTheme ->
            E.rgb255 85 85 125

        Notebook.Book.DarkTheme ->
            E.rgb255 50 50 80


themedDividerColor : Notebook.Book.Theme -> E.Color
themedDividerColor theme =
    case theme of
        Notebook.Book.LightTheme ->
            Notebook.Config.lightThemeDividerColor

        Notebook.Book.DarkTheme ->
            Notebook.Config.darkThemeDividerColor


themedPopupDividerColor : Notebook.Book.Theme -> E.Color
themedPopupDividerColor theme =
    case theme of
        Notebook.Book.LightTheme ->
            Notebook.Config.lightThemePopupDividerColor

        Notebook.Book.DarkTheme ->
            Notebook.Config.darkThemePopupDividerColor


themedValueBackgroundColor theme =
    case theme of
        Notebook.Book.LightTheme ->
            Notebook.Config.lightThemeValueBackgroundColor

        Notebook.Book.DarkTheme ->
            Notebook.Config.darkThemeValueBackgroundColor


themedBackgroundColor theme =
    case theme of
        Notebook.Book.LightTheme ->
            Notebook.Config.lightThemeBackgroundColor

        Notebook.Book.DarkTheme ->
            Notebook.Config.darkThemeBackgroundColor


themedCodeCellBackgroundColor theme =
    case theme of
        Notebook.Book.LightTheme ->
            Notebook.Config.lightThemeCodeCellBackgroundColor

        Notebook.Book.DarkTheme ->
            Notebook.Config.darkThemeCodeCellBackgroundColor


themedCodeCellTextColor theme =
    case theme of
        Notebook.Book.LightTheme ->
            Notebook.Config.lightThemeCodeCellTextColor

        Notebook.Book.DarkTheme ->
            Notebook.Config.darkThemeCodeCellTextColor


themedButtonColor tipe cstate theme =
    case theme of
        Notebook.Book.DarkTheme ->
            case cstate of
                CSView ->
                    case tipe of
                        CTCode ->
                            E.rgb 0.2 0.2 0.4

                        CTMarkdown ->
                            E.rgb 0.2 0.2 0.4

                CSEdit ->
                    case tipe of
                        CTCode ->
                            E.rgb 0.2 0.2 0.4

                        CTMarkdown ->
                            E.rgb 0.2 0.2 0.4

        Notebook.Book.LightTheme ->
            case cstate of
                CSView ->
                    case tipe of
                        CTCode ->
                            E.rgb 0.75 0.75 1.0

                        CTMarkdown ->
                            E.rgb 0.75 0.75 1.0

                CSEdit ->
                    case tipe of
                        CTCode ->
                            E.rgb 0.75 0.75 1.0

                        CTMarkdown ->
                            E.rgb 0.75 0.75 1.0


themedCodeColor theme =
    case theme of
        Notebook.Book.LightTheme ->
            Notebook.Config.lightThemeCodeColor

        Notebook.Book.DarkTheme ->
            Notebook.Config.darkThemeCodeColor


themedMutedTextColor theme =
    case theme of
        Notebook.Book.LightTheme ->
            --Notebook.Config.lightThemeTextColor
            E.rgb 0.2 0.2 0.2

        Notebook.Book.DarkTheme ->
            --Notebook.Config.darkThemeTextColor
            E.rgb255 170 160 200


themedTextColor theme =
    case theme of
        Notebook.Book.LightTheme ->
            Notebook.Config.lightThemeTextColor

        Notebook.Book.DarkTheme ->
            Notebook.Config.darkThemeTextColor


themedValueTextColor theme =
    case theme of
        Notebook.Book.LightTheme ->
            Notebook.Config.lightThemeValueTextColor

        Notebook.Book.DarkTheme ->
            Notebook.Config.darkThemeValueTextColor
