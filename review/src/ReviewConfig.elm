module ReviewConfig exposing (config)

{-| Do not rename the ReviewConfig module or the config function, because
`elm-review` will look for these.

To add packages that contain rules, add them to this review project using

    `elm install author/packagename`

when inside the directory containing this file.

-}

import CognitiveComplexity
import NoDebug.Log
import NoExposingEverything
import NoImportingEverything
import NoUnused.CustomTypeConstructors
import NoUnused.Dependencies
import NoUnused.Parameters
import NoUnused.Patterns
import NoUnused.Variables
import Review.Rule exposing (Rule)


config : List Rule
config =
    [ --NoUnused.CustomTypeConstructors.rule []
      -- NoUnused.Dependencies.rule
      NoImportingEverything.rule [ "Element" ]

    --, NoUnused.Parameters.rule
    --, NoUnused.Variables.rule
    --, NoExposingEverything.rule
    --, NoDebug.Log.rule
    , CognitiveComplexity.rule 25
    ]
        |> List.map
            (Review.Rule.ignoreErrorsForFiles
                [ "src/Env.elm" -- reports "Production" as unused constructor. This is used by Lamdera in deploy.
                ]
            )
        |> List.map (Review.Rule.ignoreErrorsForDirectories [ "src/Evergreen", "freezer/" ])
