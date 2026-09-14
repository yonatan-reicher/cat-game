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
          { text =
              { en = "Feed the beasts"
              , he = "האכילי את החיות"
              }
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
          { text =
              { en = "Boop Scoop"
              , he = "בופ סקופ"
              }
          , requirements = []
          , outcomes = [ Outcome.AddResource CatFood ]
          , returns = True
          }
    , option3 = Nothing
    }
  , { id = 3
    , name = { en = "Frequent Customer", he = "לקוח קבוע" }
    , option1 =
        Just
          { text =
              { en = "Treat them to something nice"
              , he = "תני להם משהו קטן בצד"
              }
          , requirements =
              [ Requirement (Requirement.Resource Customers) DoesntConsume
              , Requirement (Requirement.Resource Money) Consumes
              ]
          , outcomes =
              [ Outcome.AddResource Fame
              ]
          , returns = True
          }
    , option2 =
        Just
          { text =
              { en = "Offer him a job"
              , he = "תציעי לו משרה"
              }
          , requirements =
              [ Requirement (Requirement.Resource Customers) DoesntConsume
              , Requirement (Requirement.Resource Money) Consumes
              , Requirement (Requirement.Resource Money) Consumes
              , Requirement (Requirement.Resource Money) Consumes
              ]
          , outcomes =
              [ Outcome.AddResource Workers
              ]
          , returns = True
          }
    , option3 =
        Just
          { text =
              { en = "We do as much as we can"
              , he = "אנחנו עושים כל מה שאנחנו יכולים"
              }
          , requirements =
              []
          , outcomes =
              []
          , returns = True
          }
    }
  , { id = 4
    , name = { en = "Unexpected Costs", he = "עלויות לא צפויות" }
    , option1 =
        Just
          { text =
              { en = "Pay them up"
              , he = "תשלמי על הנזקים"
              }
          , requirements =
              [ Requirement (Requirement.Resource Money) Consumes
              , Requirement (Requirement.Resource Money) Consumes
              ]
          , outcomes =
              []
          , returns = True
          }
    , option2 =
        Just
          { text =
              { en = "Fix it up"
              , he = "תתקני את הנזקים"
              }
          , requirements =
              [ Requirement (Requirement.Resource Workers) DoesntConsume
              , Requirement (Requirement.Resource Money) Consumes
              ]
          , outcomes =
              [ Outcome.AddResource Workers
              ]
          , returns = True
          }
    , option3 =
        Just
          { text =
              { en = "What's some broken furniture?"
              , he = "מה רע בקצת ריהוט הרוס?"
              }
          , requirements =
              [ Requirement (Requirement.Resource Fame) Consumes
              ]
          , outcomes =
              [
              ]
          , returns = True
          }
    }
  , { id = 5
    , name = { en = "Demonic Feline", he = "חתלתול מן השאול" }
    , option1 =
        Just
          { text =
              { en = "Get him high on catnip"
              , he = "שיתמסטל על קטניפ"
              }
          , requirements =
              [ Requirement Requirement.Cat DoesntConsume
              , Requirement (Requirement.Resource CatFood) Consumes
              , Requirement (Requirement.Resource CatFood) Consumes
              ]
          , outcomes =
              []
          , returns = True
          }
    , option2 =
        Just
          { text =
              { en = "Cat behavioural specialist"
              , he = "עזרה ממוחה חתולים"
              }
          , requirements =
              [ Requirement Requirement.Cat DoesntConsume
              , Requirement (Requirement.Resource Money) Consumes
              , Requirement (Requirement.Resource Money) Consumes
              ]
          , outcomes =
              []
          , returns = False
          }
    , option3 =
        Just
          { text =
              { en = "Let the demon rage"
              , he = "תני לשד שבוא להשתולל"
              }
          , requirements =
              [ Requirement Requirement.Cat Consumes
              ]
          , outcomes =
              [ AddEvent 6
              ]
          , returns = False
          }
    }
  , { id = 6
    , name = { en = "The Demonic Feline Rages", he = "חתלתול השאול משתולל!" }
    , option1 =
        Just
          { text =
              { en = "Get him high on catnip"
              , he = "שיתמסטל על קטניפ"
              }
          , requirements =
              [ Requirement (Requirement.Resource CatFood) Consumes
              , Requirement (Requirement.Resource CatFood) Consumes
              ]
          , outcomes =
              []
          , returns = True
          }
    , option2 =
        Just
          { text =
              { en = "Film him scaring customers"
              , he = "צלמי אותו מפחיד את הלקוחות"
              }
          , requirements =
              [ Requirement (Requirement.Resource Customers) Consumes
              ]
          , outcomes =
              [ AddResource Fame
              ]
          , returns = True
          }
    , option3 =
        Just
          { text =
              { en = "Allow his rage to foster"
              , he = "תני לדחף שלו להשתלט עליו"
              }
          , requirements =
              [ Requirement (Requirement.Resource CatFood) Consumes
              , Requirement (Requirement.Resource Money) Consumes
              , Requirement (Requirement.Resource Fame) Consumes
              ]
          , outcomes =
              [ AddEvent 7
              ]
          , returns = False
          }
    }
  , { id = 7
    , name = { en = "Demonic Feline Sacrifice", he = "קורבן עבור החתלתול" }
    , option1 =
        Just
          { text =
              { en = "Do it."
              , he = "תעשי את זה."
              }
          , requirements =
              [ Requirement Requirement.Cat Consumes
              ]
          , outcomes =
              [ AddEvent 8
              ]
          , returns = False
          }
    , option2 =
        Nothing
    , option3 =
        Nothing -- TODO: lose
    }
  , { id = 8
    , name = { en = "The blood must flow", he = "הדם צריך להמשיך לזרום" }
    , option1 =
        Just
          { text =
              { en = "Do it."
              , he = "תעשי את זה."
              }
          , requirements =
              [ Requirement Requirement.Cat Consumes
              , Requirement Requirement.Cat Consumes
              , Requirement Requirement.Cat Consumes
              ]
          , outcomes =
              [ -- todo: Win!
              ]
          , returns = False
          }
    , option2 =
        Nothing
    , option3 =
        Nothing -- TODO: lose
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



