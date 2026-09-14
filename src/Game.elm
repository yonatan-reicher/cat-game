module Game exposing (..)

-- Elm stuff
import Array exposing (Array)
import Random
-- My stuff
import Exception exposing (Exception)
import Except exposing (Except, okOrStr)
import Localization exposing (..)
import Jrelm.List as JList


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


type alias Requirement =
  { kind : RequirementKind
  , consumes : Consumes
  }


type RequirementKind
  = CatRequirement
  | ResourceRequirement Resource


type Consumes
  = Consumes
  | DoesntConsume


type Outcome
  = AddEvent EventId
  | AddResource Resource


allEvents : Array Event
allEvents =
  [ { id = 1
    , name = { en = "Hungry Cats", he = "חתולים רעבים" }
    , option1 = Nothing
    , option2 =
        Just
          { text = { en = "Feed the beasts", he = "האכילי את החיות" }
          , requirements = [ Requirement (ResourceRequirement CatFood) Consumes ]
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
          , outcomes = [ AddResource CatFood ]
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
      [ Cat, ResourceCard CatFood, ResourceCard CatFood, ResourceCard CatFood ]
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


eventGetOption : OptionIdx -> Event -> Maybe Option
eventGetOption i e =
  case i of
    Option1 -> e.option1
    Option2 -> e.option2
    Option3 -> e.option3


getOption : OptionIdx -> Game -> Maybe Option
getOption i g =
  List.head g.events |> Maybe.andThen (eventGetOption i)


selectOption : OptionIdx -> Game -> Except Game
selectOption i g =
  let cards : List Card
      cards = List.filter (\c -> c.selected) g.hand |> List.map (\c -> c.card) in
  getOption i g
  |> okOrStr "no such option"
  |> Result.andThen (\option ->
    matchRequirements option.requirements cards
    |> okOrStr "requirements do not match"
    |> Result.map (\matches -> (option, matches)))
  |> Result.map (\(option, matches) ->
    matches |> List.filterMap (\(c, maybeR) -> 
      case maybeR |> Maybe.map (\r -> r.consumes) of
        Just Consumes -> Nothing
        Nothing -> Just c
        Just DoesntConsume -> Just c)
    |> \newCards ->
      { g | hand = List.map (\c -> { card = c, selected = False }) newCards })


type alias MatchedRequirements = List (Card, Maybe Requirement)


{-| Returns the list of cards, with the requirements matched against them -}
matchRequirements : List Requirement -> List Card -> Maybe MatchedRequirements
matchRequirements rs cs =
  -- TODO: sort the requirements and sort the cards
  let step card (matches, rsRest) =
        case findMatchingRequirement rsRest card of
          (maybeR, others) -> ((card, maybeR) :: matches, others)
  in cs
    |> List.foldl step ([], rs)
    |> \(matches, rsRest) ->
        if List.isEmpty rsRest then Just matches else Nothing


findMatchingRequirement : List Requirement -> Card -> (Maybe Requirement, List Requirement)
findMatchingRequirement rs c =
  case rs of
    [] -> (Nothing, rs)
    head :: tail ->
      if matchRequirement head c
      then (Just head, tail)
      else
        findMatchingRequirement tail c
        |> \(r, rest) -> (r, head :: rest)


matchRequirement : Requirement -> Card -> Bool
matchRequirement r c =
  case r.kind of
    CatRequirement -> c == Cat
    ResourceRequirement resource ->
      case c of
        ResourceCard otherResource -> resource == otherResource
        _ -> False


resourceToLString : Resource -> LString
resourceToLString r =
  case r of
    CatFood -> { en = "Cat Food", he = "אוכל חתולים" }


setCardSelected : Int -> Bool -> Game -> Game
setCardSelected i b g =
  { g | hand = JList.mapIndex i (\c -> { c | selected = b }) g.hand }
