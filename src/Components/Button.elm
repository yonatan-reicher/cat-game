module Components.Button exposing (button, style)

-- Elm
import Html exposing (Html)
import Html.Attributes exposing (class)
import Html.Events
-- Our
import LHtml exposing (LHtml, ltext)
import Localization exposing (LString)
import Jrelm.Html exposing (stylesheet)
import Palette as Pal


button
  : { onClick : msg
    , text : LString
    }
 -> LHtml msg
button { onClick, text } l =
  Html.button
    [ Html.Events.onClick onClick
    , class "button"
    ]
    [ ltext text l
    ]


style : Html x
style =
  """
  .button {
    font: inherit;
    background: BACKGROUND;
    border: none;
    border-radius: 8px;
    color: COLOR;
    padding: 8px 16px;
    transition: transform 0.1s linear, background 0.15s ease-out;
  }

  .button:hover {
    background: BACKGROUND_HOVER;
    transform: translateY(-10%);
  }
  """
  |> String.replace "BACKGROUND_HOVER" Pal.cardShadowStr
  |> String.replace "BACKGROUND" Pal.cardStr
  |> String.replace "COLOR" Pal.catWhiteStr
  |> stylesheet
