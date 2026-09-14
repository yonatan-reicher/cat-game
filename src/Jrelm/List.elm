module Jrelm.List exposing (..)


mapIndex : Int -> (a -> a) -> List a -> List a
mapIndex idx f l =
  case l of
    [] -> l
    head :: tail ->
      case idx of
        0 -> f head :: tail
        _ -> head :: mapIndex (idx - 1) f tail


dropIndex : Int -> List a -> List a
dropIndex i l =
  case (l, i) of
    ([], _) -> l
    (_ :: tail, 0) -> tail
    (head :: tail, _) -> head :: dropIndex (i - 1) tail
