module Except exposing
  ( Except
  , at
  )

import Exception exposing (Exception(..))


type alias Except a = Result Exception a


at : String -> Except a -> Except a
at f = Result.mapError (At f)
