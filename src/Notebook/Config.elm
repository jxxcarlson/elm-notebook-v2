module Notebook.Config exposing (..)

import Element as E


fastTickInterval : Float
fastTickInterval =
    60



-- DARK THEME


darkThemeBackgroundColor =
    E.rgb255 40 40 40


darkThemeCodeColor =
    E.rgb255 100 100 250


darkThemeTextColor =
    E.rgb255 200 200 200



-- Code cell dark  them


darkThemeCodeCellBackgroundColor =
    -- E.rgb255  100 100 130
    E.rgb255 80 80 110


darkThemeCodeCellTextColor =
    E.rgb255 180 180 255



-- LIGHT THEME


lightThemeBackgroundColor =
    E.rgb 0.95 0.95 0.95


lightThemeTextColor =
    E.rgb 0.2 0.2 0.2


lightThemeCodeColor =
    E.rgb 0.2 0.2 0.4


lightThemeCodeCellTextColor =
    E.rgb255 20 20 150



-- Code cell light them


lightThemeCodeCellBackgroundColor =
    E.rgb 0.85 0.85 0.95
