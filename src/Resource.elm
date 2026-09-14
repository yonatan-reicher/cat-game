module Resource exposing (..)

import Localization exposing (LString)


type Resource
  = CatFood
  | Worker
  | Customer
  | Money
  | Fame


toLString : Resource -> LString
toLString r =
  case r of
    CatFood -> { en = "Cat Food", he = "אוכל חתולים" }
    Worker -> { en = "Worker", he = "עובדים" }
    Customer -> { en = "Customer", he = "לקוחות" }
    Money -> { en = "Money", he = "כסף" }
    Fame -> { en = "Fame", he = "פרסום" }
