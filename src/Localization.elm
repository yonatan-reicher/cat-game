module Localization exposing (..)


type Local
  = English
  | Hebrew


type alias LString =
  { en : String
  , he : String
  }


lStringGet : Local -> LString -> String
lStringGet l =
  case l of
    English -> \s -> s.en
    Hebrew  -> \s -> s.he
