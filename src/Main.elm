module Main exposing (..)

-- Elm imports
import Browser exposing (Document, document)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Browser.Events exposing (onAnimationFrameDelta)
import Random
-- Our imports
import Except
import Exception exposing (Exception)
import Game exposing (..)
import Jrelm.Html exposing (stylesheet)
import Jrelm.Rgb as Rgb
import LHtml exposing (LHtml, ltext)
import Localization exposing (..)
import MainMenu as Menu
import Palette as Pal
import Components.Button
import Components.Card
import Components.Scroller as Scroller exposing (Pos)
import View.Game


type alias Flags = ()
type alias Model =
  { local : Local
  , exceptions : List Exception
  , scrollerState : Scroller.State
  , menuState : Menu.Model
  , gameState : Game
  }

type Msg
  = EmptyMsg
  | GameMsg View.Game.Msg
  | MenuMsg Menu.Msg
  | DismissException
  | ThrowException Exception
  | ScrollerTick Float


main : Program Flags Model Msg
main =
  document
  { init = init
  , view = view
  , update = update
  , subscriptions = subscriptions
  }


init : Flags -> ( Model, Cmd Msg )
init _ =
  ( { local = Hebrew
    , exceptions = []
    , scrollerState = Scroller.at { x = 0, y = 0 }
    , menuState = Menu.init
    , gameState = Game.newGame (Random.initialSeed 0)
    }
  , Cmd.none
  )


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
  [ directionStyle model.local
  , epicStylesheet
  , Components.Button.style
  , Components.Card.style
  , bodyMain model
  , case model.exceptions of
      [] -> Jrelm.Html.empty
      e :: _ -> exception e model.local
  ]


bodyMain : Model -> Html Msg
bodyMain model =
  Scroller.view
    (scrollerArgs model)
    model.scrollerState


scrollerCells : Model -> List (Pos, Html Msg)
scrollerCells m =
  [ ( { x = 0, y = 0 }
    , Menu.view m.menuState m.local |> Html.map MenuMsg
    )
  , ( { x = 0, y = -1 }
    , View.Game.game m.gameState m.local |> Html.map GameMsg
    )
  ]


scrollerArgs : Model -> Scroller.Args Msg
scrollerArgs m =
  { width = "100%"
  , height = "100%"
  , cells = scrollerCells m
  , speed = 0.002
  }


epicStylesheet : Html x
epicStylesheet =
  """
    /* Colors */
    :root {
      --text-color: COLOR;
    }

    :root {
        background: BACKGROUND;
        color: COLOR;
        font-family: "Playpen Sans Hebrew", cursive;
        font-optical-sizing: auto;
        font-weight: <weight>;
        font-style: normal;
    }

    body {
        padding: 0;
        margin: 0;
        width: 100%;
        height: 100vh;
        overflow: hidden;
    }
  """
  |> String.replace "BACKGROUND" (Rgb.toString Pal.back)
  |> String.replace "COLOR" (Rgb.toString Pal.catWhite)
  |> stylesheet


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
    [ Components.Card.card { pops = False }
        [ style "width" "100%"
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
    MenuMsg m -> menuMsg m
    GameMsg m -> gameMsg m
    DismissException -> dismissException
    ThrowException e -> throwException e
    ScrollerTick d -> scrollerTick d


newGame : Update
newGame m =
  -- TODO: Randomize
  ( { m
    | gameState = Game.newGame <| Random.initialSeed 0
    , scrollerState =
        m.scrollerState
        |> Scroller.scrollTo { x = 0, y = -1 }
    }
  , Cmd.none
  )


gameMsg : View.Game.Msg -> Update
gameMsg msg m =
  View.Game.update msg m.gameState
  |> Result.map (\(gg, c) -> ({ m | gameState = gg }, Cmd.map GameMsg c))
  |> Except.catch (\e -> throwException e m)


menuMsg : Menu.Msg -> Update
menuMsg msg m =
  case Menu.update msg m.menuState of
    Menu.AnotherMenu newMen c ->
      ( { m | menuState = newMen }
      , Cmd.map MenuMsg c
      )
    Menu.NewGame -> newGame m


dismissException : Update
dismissException m =
  ( { m | exceptions = List.tail m.exceptions |> Maybe.withDefault [] }, Cmd.none )


throwException : Exception -> Update
throwException e m =
  ( { m | exceptions = e :: m.exceptions } , Cmd.none )


scrollerTick : Float -> Update
scrollerTick d m =
  ( { m
    | scrollerState = Scroller.tick (scrollerArgs m) d m.scrollerState
    }
  , Cmd.none
  )


subscriptions : Model -> Sub Msg
subscriptions _ =
  Sub.batch
    [ onAnimationFrameDelta ScrollerTick
    ]
