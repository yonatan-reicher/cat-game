module Components.Scroller exposing
  ( State
  , Args
  , view
  , scrollTo
  , tick
  )

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


type alias Pos = { x : Float, y : Float }


type State
  = At Pos
  | Going { from : Pos, to : Pos, t : Float }


type alias Args msg =
  { cells : List (Pos, Html msg)
  , width : String
  , height : String
  }


pos : State -> Pos
pos s =
  case s of
    At p -> p
    Going { from, to, t } ->
      { x = from.x * (1 - t) + to.x * t
      , y = from.y * (1 - t) + to.y * t
      }


view : Args msg -> State -> Html msg
view args s =
  div
    [ style "position" "relative"
    , style "width" args.width
    , style "height" args.height
    ]
    (List.map (cell args) args.cells)


cell : Args msg -> (Pos, Html msg) -> Html msg
cell args ({ x, y }, c) =
  div
    [ style "position" "absolute"
    , style "width" args.width
    , style "height" args.height
    , style "left" ("calc(" ++ String.fromFloat x ++ " * " ++ args.width ++ ")")
    , style "top" ("calc(" ++ String.fromFloat y ++ " * " ++ args.height ++ ")")
    ]
    [ c
    ]


scrollTo : Pos -> State -> State
scrollTo to s = Going { from = pos s, to = to, t = 0 }


{-| first argument is delta seconds -}
tick : Float -> State -> State
tick d s =
  case s of
    At _ -> s
    Going x ->
      if x.t >= 1
      then At x.to
      else Going { x | t = x.t + d }
