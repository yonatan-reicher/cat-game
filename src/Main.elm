module Main exposing (..)

-- Elm imports
import Browser exposing (Document, document)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Random
-- Our imports
import Game exposing (..)
import Jrelm.List as JList
import Jrelm.Html exposing (stylesheet)
import Localization exposing (..)
import View exposing (styles)
import View.Game


type alias Flags = ()
type alias Model =
  { local : Local
  , modelState : ModelState
  }
type ModelState
  = Menu
  | Game Game
type Msg
  = EmptyMsg
  | NewGame
  | GameMsg View.Game.Msg


main : Program Flags Model Msg
main =
  document
  { init = init
  , view = view
  , update = update
  , subscriptions = subscriptions
  }


init : Flags -> ( Model, Cmd Msg )
init _ = ( { local = Hebrew, modelState = Menu }, Cmd.none )


view : Model -> Document Msg
view model =
  { title =
      lstringGet
        model.local
        { en = "Cat Cafe Game"
        , he = "בית קפה חתולים"
        }
  , body = body model
  }


body : Model -> List (Html Msg)
body model =
  (case model.modelState of
    Menu -> menu model
    Game g -> [View.Game.game g model.local |> Html.map GameMsg])
  |> \l -> directionStyle model.local :: styles ++ l


directionStyle : Local -> Html x
directionStyle l =
  case l of
    English -> stylesheet ""
    Hebrew ->
      stylesheet """
        :root {
          direction: rtl;
        }
      """


menu : Model -> List (Html Msg)
menu m =
  [ button
      [ onClick NewGame ]
      [ text
        <| lstringGet m.local
        <| { en = "New Game", he = "משחק חדש" }
      ]
  ]


type alias Update = Model -> ( Model, Cmd Msg )
update : Msg -> Update
update msg =
  case msg of
    EmptyMsg -> \model -> ( model, Cmd.none )
    NewGame -> newGame
    GameMsg m -> gameMsg m


newGame : Update
newGame m =
  ( { m | modelState = Game <| Game.newGame <| Random.initialSeed 0 }
  , Cmd.none
  )


gameMsg : View.Game.Msg -> Update
gameMsg msg m =
  case m.modelState of
    Game g ->
      View.Game.update msg g
      |> \(gg, c) -> ({ m | modelState = Game gg }, Cmd.map GameMsg c)
    _ -> ( m, Cmd.none ) -- TODO: Show an error


subscriptions : Model -> Sub Msg
subscriptions _ = Sub.none
