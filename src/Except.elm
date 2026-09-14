module Except exposing
  ( Except
  , at
  , catch
  , str
  , okOrStr
  )

import Exception exposing (Exception(..))


type alias Except a = Result Exception a


at : String -> Except a -> Except a
at f = Result.mapError (At f)


str : String -> Except a
str s = Err (Str s)


okOrStr : String -> Maybe a -> Except a
okOrStr s x =
  case x of
    Just a -> Ok a
    Nothing -> str s


catch : (Exception -> a) -> Except a -> a
catch f x =
  case x of
    Ok a -> a
    Err e -> f e
