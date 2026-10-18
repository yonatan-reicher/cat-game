module Card exposing (..)

import Cat exposing (Cat)
import Resource exposing (Resource)


type Card
  = Cat Cat
  | Resource Resource


type alias HandCard =
  { card : Card
  , selected : Bool
  }


isSelected : HandCard -> Bool
isSelected c = c.selected


unselect : HandCard -> HandCard
unselect c = { c | selected = False }
