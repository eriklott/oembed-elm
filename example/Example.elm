module Example exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import OEmbed exposing (..)
import Http
import Task


type alias Item =
    { id : String
    , name : String
    }


type alias Model =
    { url : String
    , result : Maybe (Result Http.Error Response)
    }


init : ( Model, Cmd Msg )
init =
    ( { url = "", result = Nothing }
    , Cmd.none
    )


type Msg
    = URLInput String
    | GetOEmbedClick
    | OEmbedResult (Result Http.Error Response)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        URLInput url ->
            ( { model | url = url }, Cmd.none )

        GetOEmbedClick ->
            ( model
            , get model.url
                |> Task.attempt OEmbedResult
            )

        OEmbedResult result ->
            ( { model | result = Just result }, Cmd.none )


view : Model -> Html Msg
view model =
    div []
        [ input [ onInput URLInput, value model.url ] []
        , button [ onClick GetOEmbedClick ] [ text "Submit" ]
        , h2 [] [ text "response" ]
        , span [] [ text (toString model.result) ]
        ]


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , subscriptions = (\_ -> Sub.none)
        , view = view
        }
