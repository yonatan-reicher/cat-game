module Event exposing (..)

import Array exposing (Array)
import Except exposing (Except)
import Localization exposing (LString)
import Outcome exposing (Outcome(..))
import Requirement exposing (Requirement, Consumes(..))
import Resource exposing (Resource(..))


-- =============================================================================
--                                     Types
-- =============================================================================


type alias Event =
  { id : EventId
  , name : LString
  , option1 : Maybe Option
  , option2 : Maybe Option
  , option3 : Maybe Option
  }


type alias EventId = Int


type OptionIdx
  = Option1
  | Option2
  | Option3


-- A way to react to an event.
type alias Option =
  { text : LString
  , requirements : List Requirement
  , outcomes : List Outcome
  , returns : Bool -- Does this event get reshuffled, or is it discarded?
  }


-- =============================================================================
--                                  Event Table
-- =============================================================================


all : Array Event
all =
  [ { id = 1
    , name = { en = "Hungry Cats", he = "חתולים רעבים" }
    , option1 = Nothing
    , option2 =
        Just
          { text = { en = "Feed the beasts", he = "האכילי את החיות" }
          , requirements = [ Requirement (Requirement.Resource CatFood) Consumes ]
          , outcomes = []
          , returns = True
          }
    , option3 = Nothing
    }
  , { id = 2
    , name = { en = "Time Passes", he = "הזמן עובר" }
    , option1 = Nothing
    , option2 =
        Just
          { text = { en = "Boop Scoop", he = "בופ סקופ" }
          , requirements = []
          , outcomes = [ Outcome.AddResource CatFood ]
          , returns = True
          }
    , option3 = Nothing
    }
  , err
  ]
  |> Array.fromList


err : Event
err =
  { id = -1
  , name = { en = "Error", he = "שגיאה" }
  , option1 = Nothing
  , option2 = Nothing
  , option3 = Nothing
  }



-- =============================================================================
--                                   Functions
-- =============================================================================


-- ------ Table ----------------------------------------------------------------


fromId : EventId -> Except Event
fromId id =
  Array.get id all
  |> Except.okOrStr ("no event with id '" ++ String.fromInt id ++ "'")


fromIdOrErr : EventId -> Event
fromIdOrErr id = fromId id |> Except.catch (\_ -> err)


-- ------ Matching -------------------------------------------------------------



