module Jrelm.Rgb exposing
  ( Rgb
  , toString
  , add
  , mul
  , fromHex
  )

import Except exposing (Except)


type alias Rgb = { r : Float, g : Float, b : Float }


toString : Rgb -> String
toString { r, g, b } =
  "rgb(" ++ String.fromFloat r
  ++ "," ++ String.fromFloat g
  ++ "," ++ String.fromFloat b
  ++ ")"


componentWise : (Float -> Float -> Float) -> Rgb -> Rgb -> Rgb
componentWise f c1 c2 =
  { r = f c1.r c2.r, g = f c1.g c2.g, b = f c1.b c2.b }


add : Rgb -> Rgb -> Rgb
add = componentWise <| \x y -> x + y


mul : Rgb -> Rgb -> Rgb
mul = componentWise <| \x y -> x * y / 255

-- =============================================================================
--                                   From Hex
-- =============================================================================


fromHex : String -> Except Rgb
fromHex s =
  s
  |> dropHash
  |> toComponents
  |> Result.andThen parseComponents
  |> Except.at "Rgb.FromHex.fromHex"


dropHash : String -> String
dropHash s =
  if String.startsWith "#" s
  then String.dropLeft 1 s
  else s


type alias CharPair = ( Char, Char )


toComponents : String -> Except ( CharPair, CharPair, CharPair )
toComponents s =
  if String.length s == 6 then
    Ok
      ( ( stringGetOrSpace 0 s, stringGetOrSpace 1 s )
      , ( stringGetOrSpace 2 s, stringGetOrSpace 3 s )
      , ( stringGetOrSpace 4 s, stringGetOrSpace 5 s )
      )
  else if String.length s == 3 then
    Ok
      ( ( stringGetOrSpace 0 s, stringGetOrSpace 0 s )
      , ( stringGetOrSpace 1 s, stringGetOrSpace 1 s )
      , ( stringGetOrSpace 2 s, stringGetOrSpace 2 s )
      )
  else 
    "'" ++ s ++ "' is not of length 3/6"
    |> Except.str
    |> Except.at "Rgb.FromHex.toComponents"


stringGetOrSpace : Int -> String -> Char
stringGetOrSpace i = stringGet i >> Maybe.withDefault ' '



stringGet : Int -> String -> Maybe Char
stringGet i s =
  s
  |> String.dropLeft i
  |> String.uncons
  |> Maybe.map Tuple.first


parseComponents : ( CharPair, CharPair, CharPair ) -> Except Rgb
parseComponents ( a, b, c ) =
  Result.map3
    Rgb
    (parseComponent a)
    (parseComponent b)
    (parseComponent c)


parseComponent : CharPair -> Except Float
parseComponent = Result.map toFloat << parseComponentToInt


parseComponentToInt : CharPair -> Except Int
parseComponentToInt (a, b) =
  Result.map2
    (\aa bb -> aa * 16 + bb)
    (parseHexDigit a)
    (parseHexDigit b)


parseHexDigit : Char -> Except Int
parseHexDigit c =
  case Char.toLower c of
    '0' -> Ok 0
    '1' -> Ok 1
    '2' -> Ok 2
    '3' -> Ok 3
    '4' -> Ok 4
    '5' -> Ok 5
    '6' -> Ok 6
    '7' -> Ok 7
    '8' -> Ok 8
    '9' -> Ok 9
    'a' -> Ok 10
    'b' -> Ok 11
    'c' -> Ok 12
    'd' -> Ok 13
    'e' -> Ok 14
    'f' -> Ok 15
    _ ->
      "char '" ++ String.fromChar c ++ "' is not a hex digit"
      |> Except.str
      |> Except.at "parseHexDigit"
