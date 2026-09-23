module Components.Card exposing
  ( cardSize
  , card
  , style
  )

-- Elm
import Html exposing (..)
import Html.Attributes exposing (..)
-- Our
import Jrelm.Html exposing (stylesheet)
import Jrelm.Rgb as Rgb
import Palette as Pal


-- There is no standard playing-card size, so we use Bicycle's sizes.
{-| Size in millimeters of cards produced by the Bicycle company. -}
bicycleCardSize : { x : number, y : number }
bicycleCardSize =
  { x = 63
  , y = 88
  }

bicycleRatio : Float
bicycleRatio = bicycleCardSize.y / bicycleCardSize.x

cardSizeX : Int
cardSizeX = 130

cardSizeY : Int
cardSizeY = round (toFloat cardSizeX * bicycleRatio)

cardSize : { x : Int, y : Int }
cardSize =
  { x = cardSizeX
  , y = cardSizeY
  }


card : { pops : Bool } -> List (Attribute msg) -> List (Html msg) -> Html msg
card { pops } attributes children =
  div
    ( class "card" :: class (if pops then "pops" else "") :: attributes )
    children


style : Html x
style =
  """
  .card {
    box-sizing: border-box;
    width: CARD_SIZE_X;
    height: CARD_SIZE_Y;
    background: BACKGROUND;
    border: none;
    border-radius: 16px;
    padding: 8px;
    overflow: clip;
    transition: transform 0.1s ease-in-out;
    position: relative;
  }

  .card::before {
    content: '';
    position: absolute;
    left: BORDER_GAP;
    top: BORDER_GAP;
    box-sizing: border-box;
    border: 7px double BORDER_COLOR;
    border-radius: calc(16px - BORDER_GAP);
    width: calc(100% - 2 * BORDER_GAP);
    height: calc(100% - 2 * BORDER_GAP);
  }

  .card.pops:hover {
    transform: translateY(-16px);
  }
  """
  |> String.replace "BACKGROUND" (Rgb.toString Pal.card)
  |> String.replace "CARD_SIZE_X" (String.fromInt cardSize.x ++ "px")
  |> String.replace "CARD_SIZE_Y" (String.fromInt cardSize.y ++ "px")
  |> String.replace "BORDER_COLOR" Pal.greenStr
  |> String.replace "BORDER_GAP" "2px"
  |> stylesheet


