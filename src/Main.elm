module Main exposing (..)

-- Elm imports
import Browser exposing (Document, document)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Random
-- Our imports
import Game exposing (..)


type alias Flags = ()
type Model
  = Menu
  | Game Game
type Msg
  = EmptyMsg
  | NewGame


main : Program Flags Model Msg
main =
  document
  { init = init
  , view = view
  , update = update
  , subscriptions = subscriptions
  }


init : Flags -> ( Model, Cmd Msg )
init flags = ( Menu, Cmd.none )


view : Model -> Document Msg
view model =
  { title = "Cat Cafe Game The Game"
  , body = body model
  }


body : Model -> List (Html Msg)
body model =
  case model of
    Menu -> menu
    Game g -> game g


menu : List (Html Msg)
menu =
  [ button
      [ onClick NewGame ]
      [ text "New Game"
      ]
  ]


game : Game -> List (Html Msg)
game g =
  [ div
      [ style "display" "flex"
      , style "flex-direction" "column"
      ]
      (hand g.hand)
  ]


hand : Hand -> List (Html Msg)
hand h = List.map card h


card : Card -> Html Msg
card c =
  case c of
    Cat -> span [] [ text "Cat" ]
    ResourceCard CatFood -> span [] [ text "Cat Food" ]


type alias Update = Model -> ( Model, Cmd Msg )
update : Msg -> Update
update msg =
  case msg of
    EmptyMsg -> \model -> ( model, Cmd.none )
    NewGame -> \_ -> ( Game <| newGame <| Random.initialSeed 0, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model = Sub.none
