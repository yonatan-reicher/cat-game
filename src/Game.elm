module Game exposing
  ( Game
  , Hand
  , newGame
  , selectOption
  , setCardSelected
  )

-- Elm stuff
import Array exposing (Array)
import Random
-- My stuff
import Card exposing (Card)
import Event exposing (Event, Option, OptionIdx(..))
import Except exposing (Except, okOrStr)
import Exception exposing (Exception)
import Jrelm.List as JList
import Localization exposing (..)
import Resource exposing (Resource(..))
import Requirement exposing (Requirement, Consumes(..))
import Outcome exposing (Outcome(..))


type alias Game =
  { hand : Hand
  , events : List Event
  , reshuffle : List Event -- These are events that will be reshuffled.
  , randomSeed : Random.Seed
  }


type alias Hand = List { card : Card, selected : Bool }


newGame : Random.Seed -> Game
newGame r =
  { hand = 
      [ Card.Cat, Card.Resource CatFood, Card.Resource CatFood, Card.Resource CatFood ]
      |> List.map (\c -> { card = c, selected = False })
  , events = Array.toList Event.all |> List.filter (\e -> e /= Event.err)
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
  getOption i g
  |> okOrStr "no such option"
  |> Result.andThen (\option ->
    case Requirement.matchAll g.hand option.requirements of
      Requirement.MatchAll cards -> Ok (option, cards)
      Requirement.NoMatchAll -> Except.str "requirements do not match")
  |> Result.andThen (\(option, cards) -> 
    case g.events of
      event :: _ -> Ok (option, cards, event)
      _ -> Except.str "there was supposed to be an event here")
  |> Result.andThen (\(option, cards, event) ->
      { g | hand = cards }
      |> applyAllOutcomes option.outcomes
      |> popEvent
      |> if option.returns then Result.map (addEvent event) else (\x -> x))
  |> Except.at "selectOption"


applyAllOutcomes : List Outcome -> Game -> Game
applyAllOutcomes os g =
  List.foldl applyOutcome g os


applyOutcome : Outcome -> Game -> Game
applyOutcome o g =
  case o of
    AddEvent e -> addEvent (Event.fromIdOrErr e) g
    AddResource r -> addCard (Card.Resource r) g


addCard : Card -> Game -> Game
addCard c g =
  { g | hand = { card = c, selected = False } :: g.hand }


addEvent : Event -> Game -> Game
addEvent e g =
  { g | reshuffle = e :: g.reshuffle }


popEvent : Game -> Except Game
popEvent g =
  case g.events of
    [] -> Except.str "event deck is empty"
    e :: es ->
      { g | events = es }
      |> (if List.isEmpty es then reshuffle else (\x -> x))
      |> Ok



setCardSelected : Int -> Bool -> Game -> Game
setCardSelected i b g =
  { g | hand = JList.mapIndex i (\c -> { c | selected = b }) g.hand }
