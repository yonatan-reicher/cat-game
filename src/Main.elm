module Main exposing (..)

-- Elm imports
import Browser exposing (Document, document)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Random
-- Our imports
import Exception exposing (Exception)
import Except exposing (Except)
import Game exposing (..)
import Jrelm.Html exposing (stylesheet)
import LHtml exposing (LHtml, ltext)
import Localization exposing (..)
import View exposing (styles)
import View.Game


type alias Flags = ()
type alias Model =
  { local : Local
  , modelState : ModelState
  , exceptions : List Exception
  }
type ModelState
  = Menu
  | Game Game
type Msg
  = EmptyMsg
  | NewGame
  | GameMsg View.Game.Msg
  | DismissException
  | ThrowException Exception


main : Program Flags Model Msg
main =
  document
  { init = init
  , view = view
  , update = update
  , subscriptions = subscriptions
  }


init : Flags -> ( Model, Cmd Msg )
init _ = ( { local = Hebrew, modelState = Menu, exceptions = [] }, Cmd.none )


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
           ++ (case model.exceptions of
                [] -> []
                e :: _ -> [exception e model.local])


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


exception : Exception -> LHtml Msg
exception e l =
  div
    [ style "position" "fixed"
    , style "top" "0"
    , style "right" "0"
    , style "width" "100%"
    , style "height" "100%"
    , style "background-color" "rgba(0,0,0,0.7)"
    , style "box-sizing" "border-box"
    , style "padding" "30%"
    , style "font-family" "monospace"
    ]
    [ div
        [ class "card"
        , style "width" "100%"
        , style "width" "100%"
        , style "background-color" "white"
        , style "padding" "16px"
        , style "display" "flex"
        , style "flex-direction" "column"
        ]
        [ p
            [ style "direction" "ltr"
            , style "flex-grow" "1"
            , style "margin-top" "0"
            ]
            [ text (Exception.toString e)
            ]
        , div
            []
            [ button
                [ style "flex-grow" "0"
                , onClick DismissException
                ]
                [ ltext { en = "Ok :(", he = "בסדר :(" } l
                ]
            ]
        ]
    ]


type alias Update = Model -> ( Model, Cmd Msg )
update : Msg -> Update
update msg =
  case msg of
    EmptyMsg -> \model -> ( model, Cmd.none )
    NewGame -> newGame
    GameMsg m -> gameMsg m
    DismissException -> dismissException
    ThrowException e -> throwException e


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
      |> Result.map (\(gg, c) -> ({ m | modelState = Game gg }, Cmd.map GameMsg c))
      |> Except.catch (\e -> throwException e m)
    _ ->
      throwException (Exception.Str "got a game msg when not in a game state") m


dismissException : Update
dismissException m =
  ( { m | exceptions = List.tail m.exceptions |> Maybe.withDefault [] }, Cmd.none )


throwException : Exception -> Update
throwException e m =
  ( { m | exceptions = e :: m.exceptions } , Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ = Sub.none
