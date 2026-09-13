module Jrelm.List exposing (..)


mapIndex : Int -> (a -> a) -> List a -> List a
mapIndex idx f l =
  case l of
    [] -> l
    head :: tail ->
      case idx of
        0 -> f head :: tail
        _ -> head :: mapIndex (idx - 1) f tail

