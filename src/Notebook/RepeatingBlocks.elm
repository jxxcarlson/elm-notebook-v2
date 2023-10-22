module Notebook.RepeatingBlocks exposing
    ( foobar
    , foobar2
    , messageItemToComparable
    , occurrenceStats
    , occurrences
    , removeLineNumberAnnotation
    , removeOneRepeatingBlock
    , removeRepeatingBlock
    , removeRepeatingBlockAt
    , subsequences
    )

import List.Extra
import Notebook.Parser
import Notebook.Types exposing (ErrorReport, MessageItem(..), StyledString)


occurrenceStats : (a -> comparable) -> List a -> List ( Int, a )
occurrenceStats toComparable items =
    let
        uniqueItems =
            List.Extra.uniqueBy toComparable items
    in
    List.map (\item -> ( occurrences item items, item )) uniqueItems


messageItemToComparable : MessageItem -> String
messageItemToComparable messageItem =
    case messageItem of
        Plain str ->
            str

        Styled styledString ->
            styledString.string



-- foobar2 = removeRepeatingBlock (List.map removeOffsetAndBar foobar)
--
--scanForLargestRepeatingBlock : List a -> List a
--scanForLargestRepeatingBlock items =


subsequences : List a -> List (List a)
subsequences list =
    let
        ns =
            List.range 0 (List.length list)
    in
    List.map (\i -> List.take i list) ns


occurrences : a -> List a -> Int
occurrences item list =
    List.filter (\x -> x == item) list |> List.length


removeLineNumberAnnotation : MessageItem -> MessageItem
removeLineNumberAnnotation messageItem =
    case messageItem of
        Plain str ->
            case Notebook.Parser.getErrorOffset str of
                Nothing ->
                    messageItem

                Just offset ->
                    let
                        target =
                            "\n\n" ++ String.fromInt offset ++ "|"

                        replacement =
                            ""

                        revisedStr =
                            String.replace target replacement str
                    in
                    Plain revisedStr

        Styled _ ->
            messageItem


type alias State a =
    { found : Bool, repeatingBlock : List a, first : a, input : List a }


removeOneRepeatingBlock : List a -> List a
removeOneRepeatingBlock items =
    removeOneRepeatingBlockHelper { removed = False, index = 0, items = items } |> .items


removeOneRepeatingBlockHelper : { removed : Bool, index : Int, items : List a } -> { removed : Bool, index : Int, items : List a }
removeOneRepeatingBlockHelper { removed, index, items } =
    if removed then
        { removed = removed, index = index, items = items }

    else
        let
            smaller =
                removeRepeatingBlockAt index items
        in
        if List.length smaller < List.length items then
            { removed = True, index = index, items = smaller }

        else if index < List.length items - 1 then
            removeOneRepeatingBlockHelper { removed = False, index = index + 1, items = items }

        else
            { removed = False, index = index, items = items }


removeRepeatingBlockAt : Int -> List a -> List a
removeRepeatingBlockAt k items =
    let
        ( before, after ) =
            List.Extra.splitAt k items
    in
    before ++ findRepeatingBlock after


removeRepeatingBlock : List a -> List a
removeRepeatingBlock items =
    let
        repeatingBlock =
            findRepeatingBlock items
    in
    removeBlock repeatingBlock items


removeBlock : List a -> List a -> List a
removeBlock keyBlock items =
    let
        ( keyBlock_, items_ ) =
            removeBlockHelper ( keyBlock, items )
    in
    keyBlock ++ items_


removeBlockHelper : ( List a, List a ) -> ( List a, List a )
removeBlockHelper ( keyBlock, items ) =
    let
        n =
            List.length keyBlock
    in
    if matchBlock keyBlock items then
        removeBlockHelper ( keyBlock, List.drop n items )

    else
        ( keyBlock, items )


{-|

    > matchBlock [1,2,3] [1,2,3,4]
    True : Bool
    > matchBlock [1,2,3] [1,2,3]
    True : Bool
    > matchBlock [1,2,3] [1,2]

    False : Bool
    > matchBlock [1,2,3] [1,2,4]
    False : Bool

-}
matchBlock : List a -> List a -> Bool
matchBlock keyBlock targetItems =
    case ( List.head keyBlock, List.head targetItems ) of
        ( Nothing, _ ) ->
            True

        ( Just _, Nothing ) ->
            False

        ( Just keyItem, Just targetItem ) ->
            if keyItem == targetItem then
                matchBlock (List.drop 1 keyBlock) (List.drop 1 targetItems)

            else
                False


{-|

    > findRepeatingBlock [1,2,3,1,2,3]
    [1,2,3]
    > findRepeatingBlock [1,2,3,1]
    [1,2,3]

-}
findRepeatingBlock : List a -> List a
findRepeatingBlock input =
    case List.head input of
        Nothing ->
            []

        Just item ->
            let
                state =
                    { found = False, repeatingBlock = [ item ], first = item, input = List.drop 1 input }
            in
            loop state |> .repeatingBlock |> List.reverse


loop : State a -> State a
loop state =
    if state.found || state.input == [] then
        state

    else
        loop (nextState state)


nextState : State a -> State a
nextState state =
    case List.head state.input of
        Nothing ->
            state

        Just item ->
            if item == state.first then
                { state | found = True, input = List.drop 1 state.input }

            else
                { state | repeatingBlock = item :: state.repeatingBlock, input = List.drop 1 state.input }


foobar =
    [ Plain "I cannot find a `Op` type:\n\n18| executeRPN : String -> Result (List Op) Int\n                                        "
    , Styled { bold = False, color = Just "RED", string = "^^", underline = False }
    , Plain "\nThese names seem close though:\n\n    "
    , Styled { bold = False, color = Just "yellow", string = "Opp", underline = False }
    , Plain "\n    "
    , Styled { bold = False, color = Just "yellow", string = "Bool", underline = False }
    , Plain "\n    "
    , Styled { bold = False, color = Just "yellow", string = "Cmd", underline = False }
    , Plain "\n    "
    , Styled { bold = False, color = Just "yellow", string = "Int", underline = False }
    , Plain "\n\nNote: Evergreen migrations need access to all custom type variants. Make sure\nboth `Op` and `Evergreen.VX.Op` are exposed.\n\n"
    , Styled { bold = False, color = Nothing, string = "Hint", underline = True }
    , Plain ": Read <https://elm-lang.org/0.19.1/imports> to see how `import`\ndeclarations work in Elm."
    , Plain "I cannot find a `Op` type:\n\n16| executeOps : List Op -> List Op\n                      "
    , Styled { bold = False, color = Just "RED", string = "^^", underline = False }
    , Plain "\nThese names seem close though:\n\n    "
    , Styled { bold = False, color = Just "yellow", string = "Opp", underline = False }
    , Plain "\n    "
    , Styled { bold = False, color = Just "yellow", string = "Bool", underline = False }
    , Plain "\n    "
    , Styled { bold = False, color = Just "yellow", string = "Cmd", underline = False }
    , Plain "\n    "
    , Styled { bold = False, color = Just "yellow", string = "Int", underline = False }
    , Plain "\n\nNote: Evergreen migrations need access to all custom type variants. Make sure\nboth `Op` and `Evergreen.VX.Op` are exposed.\n\n"
    , Styled { bold = False, color = Nothing, string = "Hint", underline = True }
    , Plain ": Read <https://elm-lang.org/0.19.1/imports> to see how `import`\ndeclarations work in Elm."
    , Plain "I cannot find a `Op` type:\n\n16| executeOps : List Op -> List Op\n                                 "
    , Styled { bold = False, color = Just "RED", string = "^^", underline = False }
    , Plain "\nThese names seem close though:\n\n    "
    , Styled { bold = False, color = Just "yellow", string = "Opp", underline = False }
    , Plain "\n    "
    , Styled { bold = False, color = Just "yellow", string = "Bool", underline = False }
    , Plain "\n    "
    , Styled { bold = False, color = Just "yellow", string = "Cmd", underline = False }
    , Plain "\n    "
    , Styled { bold = False, color = Just "yellow", string = "Int", underline = False }
    , Plain "\n\nNote: Evergreen migrations need access to all custom type variants. Make sure\nboth `Op` and `Evergreen.VX.Op` are exposed.\n\n"
    , Styled { bold = False, color = Nothing, string = "Hint", underline = True }
    , Plain ": Read <https://elm-lang.org/0.19.1/imports> to see how `import`\ndeclarations work in Elm."
    , Plain "I cannot find a `Op` type:\n\n6| executeOp : Op -> List Op -> List Op\n               "
    , Styled { bold = False, color = Just "RED", string = "^^", underline = False }
    , Plain "\nThese names seem close though:\n\n    "
    , Styled { bold = False, color = Just "yellow", string = "Opp", underline = False }
    , Plain "\n    "
    , Styled { bold = False, color = Just "yellow", string = "Bool", underline = False }
    , Plain "\n    "
    , Styled { bold = False, color = Just "yellow", string = "Cmd", underline = False }
    , Plain "\n    "
    , Styled { bold = False, color = Just "yellow", string = "Int", underline = False }
    , Plain "\n\nNote: Evergreen migrations need access to all custom type variants. Make sure\nboth `Op` and `Evergreen.VX.Op` are exposed.\n\n"
    , Styled { bold = False, color = Nothing, string = "Hint", underline = True }
    , Plain ": Read <https://elm-lang.org/0.19.1/imports> to see how `import`\ndeclarations work in Elm."
    , Plain "I cannot find a `Op` type:\n\n6| executeOp : Op -> List Op -> List Op\n                          "
    , Styled { bold = False, color = Just "RED", string = "^^", underline = False }
    , Plain "\nThese names seem close though:\n\n    "
    , Styled { bold = False, color = Just "yellow", string = "Opp", underline = False }
    , Plain "\n    "
    , Styled { bold = False, color = Just "yellow", string = "Bool", underline = False }
    , Plain "\n    "
    , Styled { bold = False, color = Just "yellow", string = "Cmd", underline = False }
    , Plain "\n    "
    , Styled { bold = False, color = Just "yellow", string = "Int", underline = False }
    , Plain "\n\nNote: Evergreen migrations need access to all custom type variants. Make sure\nboth `Op` and `Evergreen.VX.Op` are exposed.\n\n"
    , Styled { bold = False, color = Nothing, string = "Hint", underline = True }
    , Plain ": Read <https://elm-lang.org/0.19.1/imports> to see how `import`\ndeclarations work in Elm."
    , Plain "I cannot find a `Op` type:\n\n6| executeOp : Op -> List Op -> List Op\n                                     "
    , Styled { bold = False, color = Just "RED", string = "^^", underline = False }
    , Plain "\nThese names seem close though:\n\n    "
    , Styled { bold = False, color = Just "yellow", string = "Opp", underline = False }
    , Plain "\n    "
    , Styled { bold = False, color = Just "yellow", string = "Bool", underline = False }
    , Plain "\n    "
    , Styled { bold = False, color = Just "yellow", string = "Cmd", underline = False }
    , Plain "\n    "
    , Styled { bold = False, color = Just "yellow", string = "Int", underline = False }
    , Plain "\n\nNote: Evergreen migrations need access to all custom type variants. Make sure\nboth `Op` and `Evergreen.VX.Op` are exposed.\n\n"
    , Styled { bold = False, color = Nothing, string = "Hint", underline = True }
    , Plain ": Read <https://elm-lang.org/0.19.1/imports> to see how `import`\ndeclarations work in Elm."
    ]


aa =
    [ Plain "I cannot find a `Op` type: executeRPN : String -> Result (List Op) Int\n                                        "
    , Styled { bold = False, color = Just "RED", string = "^^", underline = False }
    , Plain "\nThese names seem close though:\n\n    "
    , Styled { bold = False, color = Just "yellow", string = "Opp", underline = False }
    , Plain "\n    "
    , Styled { bold = False, color = Just "yellow", string = "Bool", underline = False }
    , Plain "\n    "
    , Styled { bold = False, color = Just "yellow", string = "Cmd", underline = False }
    , Plain "\n    "
    , Styled { bold = False, color = Just "yellow", string = "Int", underline = False }
    , Plain "\n\nNote: Evergreen migrations need access to all custom type variants. Make sure\nboth `Op` and `Evergreen.VX.Op` are exposed.\n\n"
    , Styled { bold = False, color = Nothing, string = "Hint", underline = True }
    , Plain ": Read <https://elm-lang.org/0.19.1/imports> to see how `import`\ndeclarations work in Elm."
    ]


bb =
    [ Plain "I cannot find a `Op` type: executeOps : List Op -> List Op\n                      "
    , Styled { bold = False, color = Just "RED", string = "^^", underline = False }
    , Plain "\nThese names seem close though:\n\n    "
    , Styled { bold = False, color = Just "yellow", string = "Opp", underline = False }
    , Plain "\n    "
    , Styled { bold = False, color = Just "yellow", string = "Bool", underline = False }
    , Plain "\n    "
    , Styled { bold = False, color = Just "yellow", string = "Cmd", underline = False }
    , Plain "\n    "
    , Styled { bold = False, color = Just "yellow", string = "Int", underline = False }
    , Plain "\n\nNote: Evergreen migrations need access to all custom type variants. Make sure\nboth `Op` and `Evergreen.VX.Op` are exposed.\n\n"
    , Styled { bold = False, color = Nothing, string = "Hint", underline = True }
    , Plain ": Read <https://elm-lang.org/0.19.1/imports> to see how `import`\ndeclarations work in Elm."
    ]


cc =
    [ Plain "I cannot find a `Op` type: executeOps : List Op -> List Op\n                                 "
    , Styled { bold = False, color = Just "RED", string = "^^", underline = False }
    , Plain "\nThese names seem close though:\n\n    "
    , Styled { bold = False, color = Just "yellow", string = "Opp", underline = False }
    , Plain "\n    "
    , Styled { bold = False, color = Just "yellow", string = "Bool", underline = False }
    , Plain "\n    "
    , Styled { bold = False, color = Just "yellow", string = "Cmd", underline = False }
    , Plain "\n    "
    , Styled { bold = False, color = Just "yellow", string = "Int", underline = False }
    , Plain "\n\nNote: Evergreen migrations need access to all custom type variants. Make sure\nboth `Op` and `Evergreen.VX.Op` are exposed.\n\n"
    , Styled { bold = False, color = Nothing, string = "Hint", underline = True }
    , Plain ": Read <https://elm-lang.org/0.19.1/imports> to see how `import`\ndeclarations work in Elm."
    ]


dd =
    [ Plain "I cannot find a `Op` type: executeOp : Op -> List Op -> List Op\n               "
    , Styled { bold = False, color = Just "RED", string = "^^", underline = False }
    , Plain "\nThese names seem close though:\n\n    "
    , Styled { bold = False, color = Just "yellow", string = "Opp", underline = False }
    , Plain "\n    "
    , Styled { bold = False, color = Just "yellow", string = "Bool", underline = False }
    , Plain "\n    "
    , Styled { bold = False, color = Just "yellow", string = "Cmd", underline = False }
    , Plain "\n    "
    , Styled { bold = False, color = Just "yellow", string = "Int", underline = False }
    , Plain "\n\nNote: Evergreen migrations need access to all custom type variants. Make sure\nboth `Op` and `Evergreen.VX.Op` are exposed.\n\n"
    , Styled { bold = False, color = Nothing, string = "Hint", underline = True }
    , Plain ": Read <https://elm-lang.org/0.19.1/imports> to see how `import`\ndeclarations work in Elm."
    ]


ee =
    [ Plain "I cannot find a `Op` type: executeOp : Op -> List Op -> List Op\n                          "
    , Styled { bold = False, color = Just "RED", string = "^^", underline = False }
    , Plain "\nThese names seem close though:\n\n    "
    , Styled { bold = False, color = Just "yellow", string = "Opp", underline = False }
    , Plain "\n    "
    , Styled { bold = False, color = Just "yellow", string = "Bool", underline = False }
    , Plain "\n    "
    , Styled { bold = False, color = Just "yellow", string = "Cmd", underline = False }
    , Plain "\n    "
    , Styled { bold = False, color = Just "yellow", string = "Int", underline = False }
    , Plain "\n\nNote: Evergreen migrations need access to all custom type variants. Make sure\nboth `Op` and `Evergreen.VX.Op` are exposed.\n\n"
    , Styled { bold = False, color = Nothing, string = "Hint", underline = True }
    , Plain ": Read <https://elm-lang.org/0.19.1/imports> to see how `import`\ndeclarations work in Elm."
    ]


ff =
    [ Plain "I cannot find a `Op` type: executeOp : Op -> List Op -> List Op\n                                     "
    , Styled { bold = False, color = Just "RED", string = "^^", underline = False }
    , Plain "\nThese names seem close though:\n\n    "
    , Styled { bold = False, color = Just "yellow", string = "Opp", underline = False }
    , Plain "\n    "
    , Styled { bold = False, color = Just "yellow", string = "Bool", underline = False }
    , Plain "\n    "
    , Styled { bold = False, color = Just "yellow", string = "Cmd", underline = False }
    , Plain "\n    "
    , Styled { bold = False, color = Just "yellow", string = "Int", underline = False }
    , Plain "\n\nNote: Evergreen migrations need access to all custom type variants. Make sure\nboth `Op` and `Evergreen.VX.Op` are exposed.\n\n"
    , Styled { bold = False, color = Nothing, string = "Hint", underline = True }
    , Plain ": Read <https://elm-lang.org/0.19.1/imports> to see how `import`\ndeclarations work in Elm."
    ]


foobar2 =
    aa ++ bb ++ cc ++ dd ++ ee ++ ff