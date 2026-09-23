module Main exposing (..)

-- Elm imports
import Browser exposing (Document, document)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
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
import View.Game


type alias Flags = ()
type alias Model =
  { local : Local
  , modelState : ModelState
  , exceptions : List Exception
  }
type ModelState
  = Menu Menu.Model
  | Game Game
type Msg
  = EmptyMsg
  | GameMsg View.Game.Msg
  | MenuMsg Menu.Msg
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
init _ =
  ( { local = Hebrew
    , modelState = Menu Menu.init
    , exceptions = []
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
  (case model.modelState of
    Menu men -> [Menu.view men model.local |> Html.map MenuMsg]
    Game g -> [View.Game.game g model.local |> Html.map GameMsg])
  |> \l ->
      directionStyle model.local
      :: epicStylesheet
      :: Components.Button.style
      :: Components.Card.style
      :: l
      ++ (case model.exceptions of
            [] -> []
            e :: _ -> [exception e model.local])


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


menuMsg : Menu.Msg -> Update
menuMsg msg mod =
  case mod.modelState of
    Menu men ->
      case Menu.update msg men of
        Menu.AnotherMenu newMen c ->
          ( { mod | modelState = Menu newMen }
          , Cmd.map MenuMsg c
          )
        Menu.NewGame -> newGame mod
    _ ->
      throwException
        (Exception.Str "got a menu msg when not in a menu state")
        mod


dismissException : Update
dismissException m =
  ( { m | exceptions = List.tail m.exceptions |> Maybe.withDefault [] }, Cmd.none )


throwException : Exception -> Update
throwException e m =
  ( { m | exceptions = e :: m.exceptions } , Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ = Sub.none
