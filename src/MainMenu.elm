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
import View.Theme exposing (backgroundColor)


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
    , style "background" backgroundColor
    , style "padding" "0 30%"
    , style "box-sizing" "border-box"
    , style "overflow" "hidden" -- disables margin collapse
    , style "font-size" "2em"
    ]
    [ h1
        [ style "text-align" "center"
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
