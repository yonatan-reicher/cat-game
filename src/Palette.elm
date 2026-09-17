module Palette exposing
  ( card
  , cardStr
  , back
  , backStr
  , backStrong
  , backStrongStr
  , backDark
  , backDarkStr
  , green
  , greenStr
  , greenSoft
  , greenSoftStr
  , greenDark
  , greenDarkStr
  , greenDarker
  , greenDarkerStr
  , black
  , blackStr
  , blackSoft
  , blackSoftStr
  , catWhite
  , catWhiteStr
  , catWhiteShadow
  , catWhiteShadowStr
  , catSkin
  , catSkinStr
  , catSkinShadow
  , catSkinShadowStr
  )

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Jrelm.Rgb as Rgb exposing (Rgb)


card = Rgb 238 150 73
back = Rgb 253 208 144
backStrong = Rgb 246 179 109
backDark = Rgb 218 186 125
green = Rgb 113 119 68
greenSoft = Rgb 183 164 96
greenDark = Rgb 63 66 41
greenDarker = Rgb 38 40 27
black = Rgb 13 13 13
blackSoft = Rgb 26 27 20
--
catWhite = Rgb 255 237 214
catWhiteShadow = Rgb 254 222 179
catSkin = Rgb 253 209 181
catSkinShadow = Rgb 252 200 169


cardStr = Rgb.toString card
backStr = Rgb.toString back
backStrongStr = Rgb.toString backStrong
backDarkStr = Rgb.toString backDark
greenStr = Rgb.toString green
greenSoftStr = Rgb.toString greenSoft
greenDarkStr = Rgb.toString greenDark
greenDarkerStr = Rgb.toString greenDarker
blackStr = Rgb.toString black
blackSoftStr = Rgb.toString blackSoft
--
catWhiteStr = Rgb.toString catWhite
catWhiteShadowStr = Rgb.toString catWhiteShadow
catSkinStr = Rgb.toString catSkin
catSkinShadowStr = Rgb.toString catSkinShadow


all : List (String, Rgb)
all =
  [ ( "White Cat", catWhite )
  , ( "Shadow Cat White", catWhiteShadow )
  , ( "Skin Cat", catSkin )
  , ( "Shadow Cat Skin", catSkinShadow )
  --
  , ( "Card", card )
  , ( "Strong Back", backStrong )
  , ( "Back", back )
  , ( "Dark Back", backDark )
  , ( "Soft Green", greenSoft )
  , ( "Green", green )
  , ( "Dark Green", greenDark )
  , ( "Darker Green", greenDarker )
  , ( "Soft Black", blackSoft )
  , ( "Black", black )
  ]


main : Html x
main =
  div
    [ style "display" "flex"
    , style "flex-direction" "row"
    , style "align-items" "stretch"
    , style "height" "100vh"
    ]
    (all
    |> List.map (\(name, c) ->
        div
          [ style "background" (Rgb.toString c)
          , style "flex" "1"
          , style "text-align" "center"
          , style "text-shadow" "0.05em 0.05em white, 0.05em -0.05em white, -0.05em 0.05em white, -0.05em -0.05em white"
          ]
          [ text name
          ])
    |> List.reverse)
