module Exception exposing
  ( Exception(..)
  , toString
  )


type Exception
  = Str String
  | At String Exception


toString : Exception -> String
toString e =
  "Exception: " ++ str e
  ++ String.concat (List.map (\f -> "\nat '" ++ f ++ "'") (trace e)) 


str : Exception -> String
str e =
  case e of
    Str s -> s
    At _ ee -> str ee


trace : Exception -> List String
trace e =
  case e of
    Str _ -> []
    At f ee -> f :: trace ee
