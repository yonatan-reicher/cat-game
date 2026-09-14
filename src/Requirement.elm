module Requirement exposing (..)

import Card exposing (Card)
import Resource exposing (Resource)


type alias Requirement =
  { kind : Kind
  , consumes : Consumes
  }


type Kind
  = Cat
  | Resource Resource


type Consumes
  = Consumes
  | DoesntConsume


match : Card -> Requirement -> Bool
match c rq =
  case rq.kind of
    Cat ->
      case c of
        Card.Cat -> True
        _ -> False
    Resource rs -> c == Card.Resource rs
