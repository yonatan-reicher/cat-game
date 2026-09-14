module View.Game exposing (..)

-- Elm
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
-- Our
import Except exposing (Except)
import Game exposing (..)
import LHtml exposing (..)
import Localization exposing (..)
import Resource
import View.Theme exposing (cardSize)


type Msg
  = EmptyMsg
  | SetCardSelected Int Bool
  | OptionClicked OptionIdx


type OptionMsg = OptionClickedOptionMsg


game : Game -> LHtml Msg
game g l =
  div
    []
    [ maybeEvent (List.head g.events) l
    , hr [] []
    , hand g.hand l
    ]


maybeEvent : Maybe Event -> LHtml Msg
maybeEvent m =
  case m of
    Nothing -> ltext lstringEmpty
    Just e -> event e


event : Event -> LHtml Msg
event e l =
  div
    []
    [ div
        [ class "card"
        , style "margin-left" "auto"
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
        [ maybeOption e.option1 l |> Html.map (\_ -> OptionClicked Option1)
        , maybeOption e.option2 l |> Html.map (\_ -> OptionClicked Option2)
        , maybeOption e.option3 l |> Html.map (\_ -> OptionClicked Option3)
        ]
    ]


maybeOption : Maybe Option -> LHtml OptionMsg
maybeOption m =
  case m of
    Just o -> optionHelper o NotDim
    Nothing ->
      optionHelper
        { text = lstringEmpty
        , requirements = []
        , outcomes = []
        , returns = False
        }
        Dim


type DimOrNot = Dim | NotDim
optionHelper : Option -> DimOrNot -> LHtml OptionMsg
optionHelper o dim l =
  div
    [ style "position" "relative" ]
    [ div
        [ class "card"
        , class "pops"
        , style "position" "relative"
        , onClick OptionClickedOptionMsg
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
    , case dim of
        NotDim -> text ""
        Dim ->
          div
            [ class "card"
            , style "background" "black"
            , style "border-color" "black"
            , style "opacity" "0.3"
            , style "position" "absolute"
            , style "top" "0"
            , style "left" "0"
            ]
            []
    ]


requirements : List Requirement -> LHtml x
requirements rs l = span [] (List.map (\r -> requirement r l) rs)


requirement : Requirement -> LHtml x
requirement r =
  case r.kind of
    CatRequirement -> ltext { en = "Cat", he = "חתול" }
    ResourceRequirement re -> ltext <| Resource.toLString re


outcomes : List Outcome -> LHtml x
outcomes os l = span [] (List.map (\o -> outcome o l) os)


outcome : Outcome -> LHtml x
outcome o l =
  case o of
    AddEvent id ->
      let e = getEventOrErr id in
      span [] [ ltext e.name l ]
    AddResource r ->
      span [] [ ltext (Resource.toLString r) l ]


hand : Hand -> LHtml Msg
hand h l =
  div
    [ style "position" "relative"
    , style "width" <| String.fromInt handWidth ++ "px"
    , style "height" <| String.fromInt handHeight ++ "px"
    , style "margin-left" "auto"
    , style "margin-right" "auto"
    ]
    (List.indexedMap (\i c -> handCard i (List.length h) c l) h)


handCard : Int -> Int -> { card : Card, selected : Bool } -> LHtml Msg
handCard i handSize c l =
  div
    [ style "position" "absolute"
    , style "transform"
      <| "translateX(-" ++ String.fromFloat (toFloat (i * (handWidth - cardSize.x)) / toFloat (handSize - 1)) ++ "px)"
      ++ " rotate(" ++ String.fromFloat (((toFloat i + 0.5) / toFloat handSize - 0.5) * -30) ++ "deg)"
    ]
    [ card c l
      |> Html.map (\_ -> SetCardSelected i (not c.selected))
    ]


type CardMsg = CardClickedCardMsg
card : { card : Card, selected : Bool } -> LHtml CardMsg
card c l =
  div
    [ class "card"
    , class "pops"
    , if c.selected
      then style "transform" "translateY(-16px)"
      else attribute "a" "a"
    , onClick CardClickedCardMsg
    ]
    [ span
        []
        [ case c.card of
            Cat -> ltext { en = "Cat", he = "חתול" } l
            ResourceCard r -> ltext (Resource.toLString r) l
        ]
    ]


handWidth : Int
handWidth = 512
handHeight : Int
handHeight = handWidth * 2 // 3


update : Msg -> Game -> Except ( Game, Cmd Msg )
update msg g =
  case msg of
    EmptyMsg -> Ok ( g, Cmd.none )
    SetCardSelected i b -> Ok ( setCardSelected i b g, Cmd.none )
    OptionClicked i ->
      selectOption i g
      |> Result.map (\gg -> ( gg, Cmd.none ))

