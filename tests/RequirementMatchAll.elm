module RequirementMatchAll exposing (..)

import Expect
import Test exposing (..)

import Card
import Resource exposing (Resource(..))
import Requirement exposing (Consumes(..), MatchAll(..))


suite : Test
suite =
  describe "Requirement.matchAll"
    [ test "successful example" <| \() ->
        Requirement.matchAll
          [ { card = Card.Cat
            , selected = False
            }
          , { card = Card.Resource CatFood
            , selected = True
            }
          ]
          [ { kind = Requirement.Resource CatFood
            , consumes = Consumes
            }
          ]
        |> \m ->
          case m of
            MatchAll cards ->
              cards
              |> Expect.equalLists
                  [ { card = Card.Cat
                    , selected = False
                    }
                  ]
            NoMatchAll ->
              Expect.fail "returned no match"
    ]
