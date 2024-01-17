module Notebook.Config exposing (..)

import Element as E


fastTickInterval : Float
fastTickInterval =
    60


delay =
    50



-- DARK THEME


darkThemeBackgroundColor =
    E.rgb255 43 40 60


darkThemeValueBackgroundColor =
    E.rgb255 100 100 180


darkThemeValueTextColor =
    E.rgb255 220 220 255


lightThemeValueHighlightedTextColor =
    E.rgb255 10 10 10


darkThemeValueHighlightedTextColor =
    E.rgb255 255 255 255


darkThemeCodeColor =
    E.rgb255 100 100 250


darkThemeTextColor =
    E.rgb255 200 190 230


darkThemeDividerColor =
    E.rgb255 160 160 240


darkThemePopupDividerColor =
    E.rgb255 100 100 200



-- Code cell dark  them


darkThemeCodeCellBackgroundColor =
    -- E.rgb255  100 100 130
    E.rgb255 43 40 110



-- 80 80 160
-- 100 100 130


darkThemeCodeCellTextColor =
    E.rgb255 180 180 255



-- LIGHT THEME


lightThemeBackgroundColor =
    E.rgb 0.95 0.95 0.95


lightThemeValueBackgroundColor =
    E.rgb255 170 170 220


lightThemeValueTextColor =
    --E.rgb255 40 40 220
    E.rgb 0.95 0.95 0.95


lightThemeTextColor =
    E.rgb 0.2 0.2 0.2


lightThemeCodeColor =
    E.rgb 0.2 0.2 0.4


lightThemeCodeCellTextColor =
    E.rgb255 20 20 150


lightThemeDividerColor =
    E.rgb 0.1 0.1 0.85


lightThemePopupDividerColor =
    E.rgb255 40 40 100



-- Code cell light them


lightThemeCodeCellBackgroundColor =
    E.rgb 0.85 0.85 0.95
