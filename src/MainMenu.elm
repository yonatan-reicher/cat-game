module MainMenu exposing
  ( Model
  , Msg
  , Update
  , UpdateRet(..)
  , init
  , view
  , update
  )

-- Elm
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
-- Our
import LHtml exposing (LHtml, ltext)
import Localization exposing (Local, LString)
import Palette as Pal


-- =============================================================================
--                                     Types
-- =============================================================================


type alias Model =
  {
  }


type Msg
  = ClickNewGame


type UpdateRet
  = AnotherMenu Model (Cmd Msg)
  | NewGame


type alias Update = Model -> UpdateRet


-- =============================================================================
--                                     Init
-- =============================================================================


init : Model
init = {}


-- =============================================================================
--                                     View
-- =============================================================================


view : Model -> LHtml Msg
view m l =
  div
    [ style "width" "100%"
    , style "height" "100%"
    , style "background" Pal.backStr
    , style "padding" "0 30%"
    , style "box-sizing" "border-box"
    , style "overflow" "hidden" -- disables margin collapse
    , style "font-size" "2em"
    ]
    [ h1
        [ style "text-align" "center"
        , style "text-shadow" <|
            "0.5px 0.5px " ++ Pal.catWhiteShadowStr
            ++ ", 1.5px 1.5px " ++ Pal.catWhiteShadowStr
            ++ ", 2.0px 2.0px " ++ Pal.catWhiteShadowStr
            ++ ", 2.5px 2.5px " ++ Pal.catWhiteShadowStr
            ++ ", 3.0px 3.0px " ++ Pal.catWhiteShadowStr
            ++ ", 3.5px 3.5px " ++ Pal.catWhiteShadowStr
            ++ ", 4.0px 4.0px " ++ Pal.catWhiteShadowStr
            ++ ", 4.5px 4.5px " ++ Pal.catWhiteShadowStr
        ]
        [ ltext { en = "Cat Cafe", he = "קפה חתולים" } l
        ]
    , button
        [ style "font" "inherit"
        , onClick ClickNewGame
        ]
        [ ltext { en = "New Game", he = "משחק חדש" } l
        ]
    ]


-- =============================================================================
--                                    Update
-- =============================================================================


update : Msg -> Update
update msg =
  case msg of
    ClickNewGame -> \_ -> NewGame
