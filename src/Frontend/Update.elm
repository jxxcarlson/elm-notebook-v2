module Frontend.Update exposing (..)

import Browser.Navigation as Nav
import Lamdera
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
        , message = "Signed out"
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


saveIfDirty : Model -> Time.Posix -> ( Model, Cmd Msg )
saveIfDirty model time =
    if Predicate.canSave model && model.currentBook.dirty then
        let
            oldBook =
                model.currentBook

            book =
                { oldBook | dirty = False }
        in
        ( { model | currentTime = time, currentBook = book }, Lamdera.sendToBackend (SaveNotebook book) )

    else
        ( model, Cmd.none )
