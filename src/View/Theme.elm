module View.Theme exposing
  ( cardSize
  , cardStyle
  )

-- Elm
import Html exposing (..)
import Html.Attributes exposing (..)
-- Our
import Jrelm.Html exposing (stylesheet)


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


cardStyle : Html x
cardStyle =
  """
  .card {
    box-sizing: border-box;
    width: CARD_SIZE_X;
    height: CARD_SIZE_Y;
    border: 2px solid rgba(0,0,0,0.2);
    border-radius: 16px;
    padding: 8px;
    overflow: clip;
    transition: transform 0.1s ease-in-out;
  }

  .card.pops:hover {
    transform: translateY(-16px);
  }
  """
  |> String.replace "CARD_SIZE_X" (String.fromInt cardSize.x ++ "px")
  |> String.replace "CARD_SIZE_Y" (String.fromInt cardSize.y ++ "px")
  |> stylesheet

