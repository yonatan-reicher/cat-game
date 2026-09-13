module Game exposing (..)

-- Elm stuff
import Array exposing (Array)
import Random
-- My stuff
import Localization exposing (..)


type alias Game =
  { hand : Hand
  , events : EventDeck
  , reshuffle : EventDeck -- These are events that will be reshuffled.
  , randomSeed : Random.Seed
  }


type alias Hand = List { card : Card, selected : Bool }


type Card
  = Cat
  | ResourceCard Resource


type Resource
  = CatFood


type alias EventDeck = List Event


type alias Event =
  { id : EventId
  , name : LString
  , option1 : Maybe Option
  , option2 : Maybe Option
  , option3 : Maybe Option
  }


type alias EventId = Int


-- A way to react to an event.
type alias Option =
  { text : LString
  , requirements : List Requirement
  , outcomes : List Outcome
  , returns : Bool -- Does this event get reshuffled, or is it discarded?
  }


type Requirement
  = CatRequirement
  | ResourceRequirement Resource


type Outcome
  = AddEvent EventId
  | AddCard Card


allEvents : Array Event
allEvents =
  [ { id = 1
    , name = { en = "Hungry Cats", he = "חתולים רעבים" }
    , option1 = Nothing
    , option2 =
        Just
          { text = { en = "Feed the beasts", he = "האכילי את החיות" }
          , requirements = [ ResourceRequirement CatFood ]
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
          , outcomes = [ AddCard (ResourceCard CatFood) ]
          , returns = True
          }
    , option3 = Nothing
    }
  , errorEvent
  ]
  |> Array.fromList


errorEvent : Event
errorEvent =
  { id = -1
  , name = { en = "Error", he = "שגיאה" }
  , option1 = Nothing
  , option2 = Nothing
  , option3 = Nothing
  }


getEvent : EventId -> Maybe Event
getEvent id = Array.get id allEvents
getEventOrErr : EventId -> Event
getEventOrErr id = getEvent id |> Maybe.withDefault errorEvent


newGame : Random.Seed -> Game
newGame r =
  { hand = 
      [ Cat, ResourceCard CatFood ]
      |> List.map (\c -> { card = c, selected = False })
  , events = Array.toList allEvents
  , reshuffle = []
  , randomSeed = r
  }


reshuffle : Game -> Game
reshuffle g =
  let myEvents = g.events ++ g.reshuffle
      (myEventsReshuffled, s) = shuffleList myEvents g.randomSeed
  in
    { g
    | events = myEventsReshuffled
    , reshuffle = []
    , randomSeed = s
    }


shuffleList : List a -> Random.Seed -> ( List a, Random.Seed )
shuffleList l s1 =
  case l of
    [] -> ( l, s1 )
    head :: tail1 ->
      let (tail2, s2) = shuffleList tail1 s1
          (idx, s3) = Random.step (Random.int 0 <| List.length tail2) s2
          before = List.take idx tail2
          after = List.drop idx tail2
      in ( before ++ (head :: after), s3 )


-- nextEvent : Game -> Result String Game
-- nextEvent g =
--   case g.events of
--     [] ->
--       if List.isEmpty g.reshuffle
--       then Err ("the reshuffle event deck is empty")
--       else g |> reshuffle |> nextEvent
--     head :: tail -> Ok { g | events = tail }
