module View.BodyNotSignedIn exposing (..)

import Element as E exposing (Element)
import Element.Background as Background
import Element.Font as Font
import Types exposing (FrontendModel)
import UILibrary.Color
import View.Geometry
import View.Style


view : FrontendModel -> Element msg
view model =
    E.column [ E.centerX, E.spacing 18 ]
        [ E.el
            [ Font.color (E.rgb 0.8 0.8 0.8)
            , Font.size 22
            , E.centerX
            , E.paddingEach { left = 0, right = 0, top = 18, bottom = 8 }
            ]
            (E.text "Elm Notebook")
        , E.column
            [ E.spacing 12
            , E.height (E.px (View.Geometry.mainColumnHeight model))
            , E.width (E.px 600)
            , E.scrollbarY
            , E.centerX
            , Font.size 14
            , Font.color (E.rgb 0.8 0.8 0.8)
            ]
            [ E.column [ Font.size 16, E.spacing 16, E.paddingEach { left = 0, right = 0, top = 12, bottom = 48 } ]
                [ E.paragraph [ E.spacing 8 ]
                    [ E.text "Elm Notebook is a web app for writing and running Elm code. "
                    , E.text "Cells contain either text or Elm code. "
                    , E.el [ Font.italic, Font.color (E.rgb 0.65 0.65 1.0) ] (E.text "For the time being, ")
                    , E.el [ Font.italic, Font.color (E.rgb 0.65 0.65 1.0) ] (E.text "Elm Notebook cannot run any functions which produce graphics ")
                    , E.el [ Font.italic, Font.color (E.rgb 0.65 0.65 1.0) ] (E.text "or Html output.  However, stay tuned.  We are working on this. ")
                    , E.text "Look at the public notebook 'About Packages' for information about using packages in Elm Notebook."
                    ]
                , E.column [ E.spacing 6 ]
                    [ E.image [ E.width (E.px 600), E.centerX, E.centerY ]
                        { src = "https://imagedelivery.net/9U-0Y4sEzXlO6BXzTnQnYQ/94d42afa-2246-4d63-ba08-f5e53b36b800/public"
                        , description = "Cells in Elm Notebook"
                        }
                    , E.el [ Font.color UILibrary.Color.lightGray ] (E.text "Screenshot")
                    ]
                , E.column [ E.spacing 6 ]
                    [ E.image [ E.width (E.px 600), E.centerX, E.centerY ]
                        { src = "https://imagedelivery.net/9U-0Y4sEzXlO6BXzTnQnYQ/bdd5f465-bf3e-4696-3773-b11eb7993600/public"
                        , description = "Editing a cell"
                        }
                    , E.el [ Font.color UILibrary.Color.lightGray ] (E.text "Screenshot: user clicked on a cell to edit it.")
                    ]
                , E.paragraph [ Font.italic, Font.color (E.rgb 0.65 0.65 1.0) ]
                    [ E.text "Click on the \"Sign in as Guest,\" button to view and run a \"Welcome notebook.\" It also gives directions on how to edit cells and run the code in them.  (See blue link above, center.)" ]

                --, E.paragraph [ E.spacing 8, Font.italic ]
                --    [ E.text "To create and save notebooks: (1) Sign up. "
                --    , E.text "(2) To edit a cell, click on the \"Cell\" label in the upper right corner of the cell. "
                --    , E.text "(3) To close a cell or run its code, type ctrl-Enter (or click on the cell label again, or click on \"Run\")."
                --    ]
                , E.paragraph [ E.spacing 8 ]
                    [ E.text "Elm-notebook runs code by talking to the Elm compiler. "
                    , E.text "Many thanks to Evan Czaplicki and Mario Rogic."
                    ]
                , E.paragraph [ E.spacing 8, E.paddingEach { left = 0, right = 0, top = 24, bottom = 0 } ]
                    [ E.text "Note that elm-notebook now has error messages (straight from the Elm compiler)."
                    ]
                , E.column [ E.spacing 6 ]
                    [ E.image [ E.width (E.px 600), E.centerX, E.centerY ]
                        { src = "https://imagedelivery.net/9U-0Y4sEzXlO6BXzTnQnYQ/ab00a3a1-ab05-4655-8c9d-3f38046f3700/public"
                        , description = "Error message"
                        }
                    ]
                ]
            ]
        ]
