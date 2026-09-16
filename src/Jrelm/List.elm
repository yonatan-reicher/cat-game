module Jrelm.List exposing (..)


get : Int -> List a -> Maybe a
get i l =
  case l of
    [] -> Nothing
    h :: t -> if i == 0 then Just h else get (i - 1) t


flatten : List (List a) -> List a
flatten = List.concat


flatMap : (a -> List b) -> List a -> List b
flatMap = List.concatMap


zip : List a -> List b -> List (a, b)
zip = List.map id


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


composeAll : List (a -> a) -> (a -> a)
composeAll = List.foldl (\f g -> g << f) identity
