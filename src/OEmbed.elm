module OEmbed
    exposing
        ( Response(..)
        , VimeoResponse
        , YouTubeResponse
        , get
        )

{-| OEmbed client library for various providers

@docs Response, VimeoResponse, YouTubeResponse, get

-}

import Http
import Json.Decode as Json
import Json.Decode.Extra exposing ((|:))
import Task exposing (Task)


{-| OEmbed provider responses
-}
type Response
    = YouTube YouTubeResponse
    | Vimeo VimeoResponse


{-| Create a task that gets OEmbed data for a specified url. The OEmbed
provider will be automatically determined based on the url.
-}
get : String -> Task Http.Error Response
get url =
    let
        noembedURL =
            "http://noembed.com/embed?url=" ++ Http.encodeUri (url)
    in
        Http.get noembedURL responseDecoder
            |> Http.toTask


{-| Vimeo OEmbed response
-}
type alias VimeoResponse =
    { type_ : String
    , version : String
    , title : String
    , isPlus : String
    , html : String
    , width : Int
    , height : Int
    , duration : Int
    , description : String
    , uploadDate : String
    , videoID : Int
    , uri : String
    , authorName : String
    , authorURL : String
    , providerName : String
    , providerURL : String
    , thumbnailURL : String
    , thumbnailWidth : Int
    , thumbnailHeight : Int
    }


{-| YouTube OEmbed response
-}
type alias YouTubeResponse =
    { title : String
    , html : String
    , version : String
    , height : Int
    , width : Int
    , type_ : String
    , authorName : String
    , authorURL : String
    , providerName : String
    , providerURL : String
    , thumbnailURL : String
    , thumbnailWidth : Int
    , thumbnailHeight : Int
    }


responseDecoder : Json.Decoder Response
responseDecoder =
    Json.field "provider_name" Json.string
        |> Json.andThen providerDecoder


providerDecoder : String -> Json.Decoder Response
providerDecoder providerName =
    case providerName of
        "YouTube" ->
            Json.map YouTube youTubeDecoder

        "Vimeo" ->
            Json.map Vimeo vimeoDecoder

        _ ->
            Json.fail ("Unsupported oembed provider: " ++ providerName)


vimeoDecoder : Json.Decoder VimeoResponse
vimeoDecoder =
    Json.succeed VimeoResponse
        |: (Json.field "type" Json.string)
        |: (Json.field "version" Json.string)
        |: (Json.field "title" Json.string)
        |: (Json.field "is_plus" Json.string)
        |: (Json.field "html" Json.string)
        |: (Json.field "width" Json.int)
        |: (Json.field "height" Json.int)
        |: (Json.field "duration" Json.int)
        |: (Json.field "description" Json.string)
        |: (Json.field "upload_date" Json.string)
        |: (Json.field "video_id" Json.int)
        |: (Json.field "uri" Json.string)
        |: (Json.field "author_name" Json.string)
        |: (Json.field "author_url" Json.string)
        |: (Json.field "provider_name" Json.string)
        |: (Json.field "provider_url" Json.string)
        |: (Json.field "thumbnail_url" Json.string)
        |: (Json.field "thumbnail_width" Json.int)
        |: (Json.field "thumbnail_height" Json.int)


youTubeDecoder : Json.Decoder YouTubeResponse
youTubeDecoder =
    Json.succeed YouTubeResponse
        |: (Json.field "title" Json.string)
        |: (Json.field "html" Json.string)
        |: (Json.field "version" Json.string)
        |: (Json.field "height" Json.int)
        |: (Json.field "width" Json.int)
        |: (Json.field "type" Json.string)
        |: (Json.field "author_name" Json.string)
        |: (Json.field "author_url" Json.string)
        |: (Json.field "provider_name" Json.string)
        |: (Json.field "provider_url" Json.string)
        |: (Json.field "thumbnail_url" Json.string)
        |: (Json.field "thumbnail_width" Json.int)
        |: (Json.field "thumbnail_height" Json.int)
