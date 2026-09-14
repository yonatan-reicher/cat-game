module Jrelm.Html exposing (..)

import Html exposing (..)


stylesheet : String -> Html x
stylesheet t = node "style" [] [ text t ]
