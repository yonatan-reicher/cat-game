module Localization exposing (..)


type Local
  = English
  | Hebrew


type alias LString =
  { en : String
  , he : String
  }


lstringGet : Local -> LString -> String
lstringGet l =
  case l of
    English -> \s -> s.en
    Hebrew  -> \s -> s.he


lstringEmpty : LString
lstringEmpty = { en = "", he = "" }


type alias WithLocal a = { a | local : Local }
