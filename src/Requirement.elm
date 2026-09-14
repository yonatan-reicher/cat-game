module Requirement exposing
  ( Requirement
  , Kind(..)
  , Consumes(..)
  , matchAll
  , MatchAll(..)
  )

import Card exposing (Card, HandCard)
import Resource exposing (Resource)
import Jrelm.List as JList


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


type FindMatch
  = Match Int
  | NoMatch

findMatchingIndex : List HandCard -> Requirement -> FindMatch
findMatchingIndex cards r =
  case cards of
    [] -> NoMatch
    c :: cs ->
      if c.selected && match c.card r
      then Match 0
      else
        case findMatchingIndex cs r of
          Match i -> Match (i + 1)
          NoMatch -> NoMatch


type MatchAll
  = MatchAll (List HandCard)
  | NoMatchAll


matchAll : List HandCard -> List Requirement -> MatchAll
matchAll cards requirements =
  case requirements of
    [] -> matchAllFinish cards
    r :: rs ->
      case findMatchingIndex cards r of
        NoMatch -> NoMatchAll
        Match i ->
          cards
          -- Modify the card
          |> (case r.consumes of
            Consumes -> JList.dropIndex i
            DoesntConsume -> JList.mapIndex i Card.unselect)
          -- Run the rest
          |> (\cs -> matchAll cs rs)



matchAllFinish : List HandCard -> MatchAll
matchAllFinish cards =
  if List.any Card.isSelected cards
  then NoMatchAll
  else MatchAll cards
