module Components.Scroller exposing
  ( Args
  , State
  , Pos
  , view
  , scrollTo
  , tick
  , at
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
  , speed : Float
  }


pos : State -> Pos
pos s =
  case s of
    At p -> p
    Going { from, to, t } ->
      { x = from.x * (1 - f t) + to.x * f t
      , y = from.y * (1 - f t) + to.y * f t
      }


g : Float -> Float
g x =
  let a = 0.1 in
  if x < a
  then f (x / (2 * a))
  else f ( (x - 1) / (2 - 2 * a) + 1 )


f : Float -> Float
f x =
  if x < 0.5
  then (1.0 - sqrt (1.0 - (2.0 * x) ^ 2.0)) / 2.0
  else (sqrt (1.0 - (-2.0 * x + 2.0) ^ 2.0) + 1.0) / 2.0


view : Args msg -> State -> Html msg
view args s =
  div
    [ style "position" "relative"
    , style "width" args.width
    , style "height" args.height
    , style "transform" (transform args s)
    ]
    (List.map (cell args) args.cells)


transform : Args msg -> State -> String
transform a s =
  "translate(calc("
  ++ String.fromFloat (pos s).x ++ " * " ++ a.width ++ "), calc("
  ++ String.fromFloat (pos s).y ++ " * " ++ a.height ++ "))"


cell : Args msg -> (Pos, Html msg) -> Html msg
cell args ({ x, y }, c) =
  div
    [ style "position" "absolute"
    , style "width" args.width
    , style "height" args.height
    , style "left" ("calc(" ++ String.fromFloat x ++ " * " ++ args.width ++ ")")
    , style "bottom" ("calc(" ++ String.fromFloat y ++ " * " ++ args.height ++ ")")
    ]
    [ c
    ]


at : Pos -> State
at = At


scrollTo : Pos -> State -> State
scrollTo to s = Going { from = pos s, to = to, t = 0 }


{-| first argument is delta seconds -}
tick : Args msg -> Float -> State -> State
tick a d s =
  case s of
    At _ -> s
    Going x ->
      if x.t >= 1
      then At x.to
      else Going { x | t = x.t + d * a.speed |> Basics.min 1.0 }
