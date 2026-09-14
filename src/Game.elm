module Game exposing (..)

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
  , events = Array.toList Event.all
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
      if Requirement.match c head
      then (Just head, tail)
      else
        findMatchingRequirement tail c
        |> \(r, rest) -> (r, head :: rest)


setCardSelected : Int -> Bool -> Game -> Game
setCardSelected i b g =
  { g | hand = JList.mapIndex i (\c -> { c | selected = b }) g.hand }
