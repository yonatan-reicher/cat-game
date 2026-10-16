module View.Game exposing (..)

-- Elm
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
-- Our
import Card exposing (Card)
import Components.Card exposing (cardSize)
import Event exposing (Event, Option, OptionIdx(..))
import Except exposing (Except)
import Game exposing (..)
import LHtml exposing (..)
import Localization exposing (..)
import Outcome exposing (Outcome(..))
import Palette as Pal
import Requirement exposing (Requirement, MatchAll(..))
import Resource


type Msg
  = EmptyMsg
  | SetCardSelected Int Bool
  | OptionClicked OptionIdx


type OptionMsg = OptionClickedOptionMsg


game : Game -> LHtml Msg
game g l =
  div
    [ style "height" "100vh"
    , style "display" "flex"
    , style "flex-direction" "column"
    ]
    [ maybeEvent g.hand (List.head g.events) l
    , hr
        [ style "box-sizing" "border-box"
        , style "width" "100%"
        ]
        []
    , hand g.hand l
    ]


maybeEvent : Hand -> Maybe Event -> LHtml Msg
maybeEvent h m =
  case m of
    Nothing -> \_ -> text "Error: This shouldnt happen" -- TODO: Make the list in the game non empty
    Just e -> event h e


event : Hand -> Event -> LHtml Msg
event h e l =
  div
    [ style "margin" "64px"
    ]
    [ Components.Card.card
        { pops = False
        , onClick = Nothing
        , dim = 0.0
        }
        [ style "margin-left" "auto"
        , style "margin-right" "auto"
        ]
        [ h2
            [ style "text-align" "center"
            ]
            [ ltext e.name l ]
        ]
    , div
        [ style "display" "flex"
        , style "flex-direction" "row"
        , style "justify-content" "center"
        , style "gap" "8px"
        , style "margin-top" "8px"
        ]
        [ maybeOption h e.option1 l |> Html.map (\_ -> OptionClicked Option1)
        , maybeOption h e.option2 l |> Html.map (\_ -> OptionClicked Option2)
        , maybeOption h e.option3 l |> Html.map (\_ -> OptionClicked Option3)
        ]
    ]


maybeOption : Hand -> Maybe Option -> LHtml OptionMsg
maybeOption h m =
  case m of
    Just o ->
      optionHelper o
      <| case Requirement.matchAll h o.requirements of
          MatchAll _ -> NoDim
          NoMatchAll -> Dim DimWeak
    Nothing ->
      optionHelper
        { text = lstringEmpty
        , requirements = []
        , outcomes = []
        , returns = False
        }
        (Dim DimStrong)


type Dim
  = Dim DimStrength
  | NoDim
type DimStrength
  = DimStrong
  | DimWeak
optionHelper : Option -> Dim -> LHtml OptionMsg
optionHelper o dim l =
  Components.Card.card
    { pops = dim == NoDim
    , onClick = if dim == NoDim then Just OptionClickedOptionMsg else Nothing
    , dim =
        case dim of
          Dim DimStrong -> 0.4
          Dim DimWeak -> 0.2
          NoDim -> 0.0
    }
    [ style "position" "relative"
    ]
    [ span
        [ style "text-align" "center"
        ]
        [ ltext o.text l ]
    , hr [] []
    , requirements o.requirements l
    , hr [] []
    , outcomes o.outcomes l
    ]


requirements : List Requirement -> LHtml x
requirements rs l = div [] (List.map (\r -> requirement r l) rs)


requirement : Requirement -> LHtml x
requirement r l =
  ( case r.kind of
      Requirement.Cat -> ltext { en = "Cat", he = "חתול" } l
      Requirement.Resource re -> ltext (Resource.toLString re) l
  )
  |> List.singleton
  |> div []


outcomes : List Outcome -> LHtml x
outcomes os l = div [] (List.map (\o -> outcome o l) os)


outcome : Outcome -> LHtml x
outcome o l =
  case o of
    AddEvent id ->
      let e = Event.fromIdOrErr id in
      div [] [ ltext e.name l ]
    AddResource r ->
      div [] [ ltext (Resource.toLString r) l ]


hand : Hand -> LHtml Msg
hand h l =
  div
    [ style "position" "relative"
    , style "width" <| String.fromInt handWidth ++ "vw"
    , style "flex-grow" "1"
    , style "margin-left" "auto"
    , style "margin-right" "auto"
    , style "background" Pal.greenDarkStr
    , style "border-radius" "32px 32px 0px 0px"
    , style "padding" "64px"
    ]
    (List.indexedMap (\i c -> handCard i (List.length h) c l) h)


handCard : Int -> Int -> { card : Card, selected : Bool } -> LHtml Msg
handCard i handSize c l =
  div
    [ style "position" "absolute"
    , style "transform"
      <| ("translateX(calc(-I * (HWvw - CSXpx) / (HS - 1)))"
          |> String.replace "I" (String.fromInt i)
          |> String.replace "HW" (String.fromInt handWidth)
          |> String.replace "CSX" (String.fromInt cardSize.x)
          |> String.replace "HS" (String.fromInt handSize))
      ++ " rotate(" ++ String.fromFloat (((toFloat i + 0.5) / toFloat handSize - 0.5) * -30) ++ "deg)"
    ]
    [ card c l
      |> Html.map (\_ -> SetCardSelected i (not c.selected))
    ]


type CardMsg = CardClickedCardMsg
card : { card : Card, selected : Bool } -> LHtml CardMsg
card c l =
  Components.Card.card
    { pops = True
    , onClick = Just CardClickedCardMsg
    , dim = 0.0
    }
    [ if c.selected
      then style "transform" "translateY(-16px)"
      else attribute "a" "a"
    ]
    [ span
        []
        [ case c.card of
            Card.Cat -> ltext { en = "Cat", he = "חתול" } l
            Card.Resource r -> ltext (Resource.toLString r) l
        ]
    ]


handWidth : Int
handWidth = 80


update : Msg -> Game -> Except ( Game, Cmd Msg )
update msg g =
  case msg of
    EmptyMsg -> Ok ( g, Cmd.none )
    SetCardSelected i b -> Ok ( setCardSelected i b g, Cmd.none )
    OptionClicked i ->
      selectOption i g
      |> Result.map (\gg -> ( gg, Cmd.none ))

