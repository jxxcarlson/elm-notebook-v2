module Frontend.Update exposing (periodicAction, signOut)

import Browser.Navigation as Nav
import Lamdera
import Message
import Predicate
import Time
import Types exposing (FrontendModel, FrontendMsg(..), ToBackend(..))


type alias Model =
    FrontendModel


type alias Msg =
    FrontendMsg


signOut : Model -> ( Model, Cmd Msg )
signOut model =
    ( { model
        | currentUser = Nothing
        , inputUsername = ""
        , inputPassword = ""
        , clockState = Types.ClockStopped
      }
    , Cmd.batch
        [ Nav.pushUrl model.key "/"
        , if Predicate.canSave model then
            let
                oldBook =
                    model.currentBook

                book =
                    { oldBook | dirty = False }
            in
            Lamdera.sendToBackend (SaveNotebook book)

          else
            Cmd.none
        ]
    )


periodicAction : Model -> Time.Posix -> ( Model, Cmd Msg )
periodicAction model time =
    let
        oldBook =
            model.currentBook

        decrementHighlightTime cell =
            { cell
                | highlightTime =
                    if cell.highlightTime <= 0 then
                        0

                    else
                        cell.highlightTime - 1
            }

        book =
            { oldBook | dirty = False, cells = List.map decrementHighlightTime oldBook.cells }
    in
    if Predicate.canSave model && model.currentBook.dirty then
        ( { model | currentTime = time, currentBook = book }, Lamdera.sendToBackend (SaveNotebook book) )

    else
        ( { model | currentBook = book }, Cmd.none )
