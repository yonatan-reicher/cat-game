module Main exposing (..)

-- Elm imports
import Browser exposing (Document, document)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Random
-- Our imports
import Localization exposing (..)
import Game exposing (..)
import Jrelm.List as JList


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
  | SetCardSelected Int Bool


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
      lStringGet
        model.local
        { en = "Cat Cafe Game"
        , he = "בית קפה חתולים"
        }
  , body = body model
  }


body : Model -> List (Html Msg)
body model =
  case model.modelState of
    Menu -> menu model
    Game g -> game model g


menu : Model -> List (Html Msg)
menu m =
  [ button
      [ onClick NewGame ]
      [ text
        <| lStringGet m.local
        <| { en = "New Game", he = "משחק חדש" }
      ]
  ]


game : Model -> Game -> List (Html Msg)
game model g =
  [ event model (List.head g.events)
  , div
      [ style "height" "2px"
      , style "background-color" "black"
      ]
      []
  , div
      [ style "display" "flex"
      , style "flex-direction" "column"
      , style "align-items" "center"
      ]
      (hand model g.hand)
  ]


hand : Model -> Hand -> List (Html Msg)
hand m h = List.indexedMap (card m) h


card : Model -> Int -> { card : Card, selected : Bool } -> Html Msg
card m index c =
  let f =
        span [ onClick (SetCardSelected index (not c.selected)) ]
        << if c.selected then List.singleton << b [] else (\x -> x)
  in
  case c.card of
    Cat ->
      f
        [ text
          <| lStringGet m.local
          <| { en = "Kitty", he = "חתולי" }
        ]
    ResourceCard CatFood ->
      f
        [ text
          <| lStringGet m.local
          <| { en = "Cat Food", he = "אוכל חתולים" }
        ]


event : Model -> Maybe Event -> Html Msg
event m maybe =
  div
    []
  <| case maybe of
      Nothing -> []
      Just e ->
        [ h3 [] [ text <| lStringGet m.local e.name ]
        , div
            [ style "display" "flex"
            , style "flex-direction" "row"
            , style "justify-content" "center"
            ]
            [ option m e.option1
            , option m e.option2
            , option m e.option3
            ]
        ]


option : Model -> Maybe Option -> Html Msg
option m maybeO =
  case maybeO of
    Nothing -> div [] []
    Just o ->
      div
        []
        [ text <| lStringGet m.local o.text
        ]


type alias Update = Model -> ( Model, Cmd Msg )
update : Msg -> Update
update msg =
  case msg of
    EmptyMsg -> \model -> ( model, Cmd.none )
    NewGame -> newGame
    SetCardSelected index v -> setCardSelected index v


newGame : Update
newGame m =
  ( { m | modelState = Game <| Game.newGame <| Random.initialSeed 0 }
  , Cmd.none
  )


setCardSelected : Int -> Bool -> Update
setCardSelected index v m =
  case m.modelState of
    Menu -> ( m, Cmd.none ) -- TODO: Panic. This shouldn't happen.
    Game g ->
      ( { m
        | modelState = 
            Game
              { g
              | hand =
                  JList.mapIndex index (\c -> { c | selected = v }) g.hand
              }
        }
      , Cmd.none
      )


subscriptions : Model -> Sub Msg
subscriptions _ = Sub.none
