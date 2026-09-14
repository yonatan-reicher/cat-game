module Resource exposing (..)

import Localization exposing (LString)


type Resource
  = CatFood
  | Workers
  | Customers
  | Money
  | Fame


toLString : Resource -> LString
toLString r =
  case r of
    CatFood -> { en = "Cat Food", he = "אוכל חתולים" }
    Workers -> { en = "Worker", he = "עובדים" }
    Customers -> { en = "Customer", he = "לקוחות" }
    Money -> { en = "Money", he = "כסף" }
    Fame -> { en = "Fame", he = "פרסום" }
