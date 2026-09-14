module Outcome exposing (..)

import Resource exposing (Resource)


type alias EventId = Int


type Outcome
  = AddEvent EventId
  | AddResource Resource
