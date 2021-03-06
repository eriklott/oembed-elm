module OEmbed
    exposing
        ( Response(..)
        , VimeoVideo
        , YouTubeVideo
        , get
        )

{-| OEmbed client library for various providers

@docs Response, VimeoVideo, YouTubeVideo, get

-}

import Http
import Json.Decode as Json
import Json.Decode.Extra exposing ((|:))
import Task exposing (Task)


{-| OEmbed provider responses
-}
type Response
    = YouTubeVideoResponse YouTubeVideo
    | VimeoVideoResponse VimeoVideo


{-| Vimeo OEmbed response
-}
type alias VimeoVideo =
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
type alias YouTubeVideo =
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


{-| Create a task that gets OEmbed data for a specified url. The OEmbed
provider will be automatically determined based on the url.
-}
get : String -> Task Http.Error Response
get url =
    let
        noembedURL =
            "https://noembed.com/embed?url=" ++ Http.encodeUri (url)
    in
        Http.get noembedURL responseDecoder
            |> Http.toTask


responseDecoder : Json.Decoder Response
responseDecoder =
    Json.field "provider_name" Json.string
        |> Json.andThen providerDecoder


providerDecoder : String -> Json.Decoder Response
providerDecoder providerName =
    case providerName of
        "YouTube" ->
            youTubeDecoder

        "Vimeo" ->
            vimeoDecoder

        _ ->
            Json.fail ("Unsupported oembed provider: " ++ providerName)


vimeoDecoder : Json.Decoder Response
vimeoDecoder =
    Json.field "type" Json.string
        |> Json.andThen vimeoMediaDecoder


vimeoMediaDecoder : String -> Json.Decoder Response
vimeoMediaDecoder type_ =
    case type_ of
        "video" ->
            vimeoVideoDecoder

        _ ->
            Json.fail ("Unsupported vimeo media type: " ++ type_)


vimeoVideoDecoder : Json.Decoder Response
vimeoVideoDecoder =
    Json.map VimeoVideoResponse <|
        Json.succeed VimeoVideo
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


youTubeDecoder : Json.Decoder Response
youTubeDecoder =
    Json.field "type" Json.string
        |> Json.andThen youTubeMediaDecoder


youTubeMediaDecoder : String -> Json.Decoder Response
youTubeMediaDecoder type_ =
    case type_ of
        "video" ->
            youTubeVideoDecoder

        _ ->
            Json.fail ("Unsupported youtube media type: " ++ type_)


youTubeVideoDecoder : Json.Decoder Response
youTubeVideoDecoder =
    Json.map YouTubeVideoResponse <|
        Json.succeed YouTubeVideo
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
