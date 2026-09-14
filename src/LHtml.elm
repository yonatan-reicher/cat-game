module LHtml exposing (..)

import Html exposing (Html)
import Localization exposing (..)


type alias LHtml a = Local -> Html a



fromHtml : Html a -> LHtml a
fromHtml h = \_ -> h


toHtml : Local -> LHtml a -> Html a
toHtml l h = h l


ltext : LString -> LHtml a
ltext t = \l -> Html.text <| lstringGet l t
