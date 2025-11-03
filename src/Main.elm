port module Main exposing (main)

import Browser
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html
import Json.Decode as Decode


-- PORTS
port jsonToYaml : String -> Cmd msg
port yamlToJson : String -> Cmd msg
port onJsonToYaml : (String -> msg) -> Sub msg
port onYamlToJson : (String -> msg) -> Sub msg
port onError : (String -> msg) -> Sub msg
port copyToClipboard : String -> Cmd msg


-- MODEL

type Direction
    = JsonToYaml
    | YamlToJson


type alias Model =
    { direction : Direction
    , jsonInput : String
    , yamlInput : String
    , output : String
    , errorMsg : Maybe String
    , dark : Bool
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { direction = JsonToYaml
      , jsonInput = "{\n  \"hello\": \"world\"\n}"
      , yamlInput = "hello: world\n"
      , output = ""
      , errorMsg = Nothing
      , dark = True
      }
    , Cmd.none
    )


-- UPDATE

type Msg
    = ToggleDirection
    | ToggleTheme
    | UpdateJson String
    | UpdateYaml String
    | DoConvert
    | GotJsonToYaml String
    | GotYamlToJson String
    | GotError String
    | CopyOutput


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ToggleDirection ->
            ( { model
                | direction =
                    case model.direction of
                        JsonToYaml -> YamlToJson
                        YamlToJson -> JsonToYaml
                , output = ""
                , errorMsg = Nothing
              }
            , Cmd.none
            )

        ToggleTheme ->
            ( { model | dark = not model.dark }, Cmd.none )

        UpdateJson s ->
            ( { model | jsonInput = s }, Cmd.none )

        UpdateYaml s ->
            ( { model | yamlInput = s }, Cmd.none )

        DoConvert ->
            case model.direction of
                JsonToYaml ->
                    ( { model | errorMsg = Nothing, output = "" }
                    , jsonToYaml model.jsonInput
                    )

                YamlToJson ->
                    ( { model | errorMsg = Nothing, output = "" }
                    , yamlToJson model.yamlInput
                    )

        GotJsonToYaml s ->
            ( { model | output = s, errorMsg = Nothing }, Cmd.none )

        GotYamlToJson s ->
            ( { model | output = s, errorMsg = Nothing }, Cmd.none )

        GotError e ->
            ( { model | errorMsg = Just e, output = "" }, Cmd.none )

        CopyOutput ->
            ( model, copyToClipboard model.output )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ onJsonToYaml GotJsonToYaml
        , onYamlToJson GotYamlToJson
        , onError GotError
        ]


-- VIEW

main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


view : Model -> Html.Html Msg
view model =
    layout (themeBody model.dark) <|
        column [ width fill, height fill, spacing 24, padding 24 ]
            [ headerBar model
            , converterArea model
            ]


headerBar : Model -> Element Msg
headerBar model =
    row
        [ width fill
        , spacing 16
        , paddingXY 4 8
        , Border.width 1
        , Border.rounded 16
        , Border.color (onDark model (rgba 1 1 1 0.15))
        , Background.color (onDark model (rgba 0.96 0.965 0.98 0.1))
        ]
        [ el [ Font.size 24, Font.bold ] (text "jy-converter")
        , el [ Font.color (rgb255 130 130 255) ] (text " • JSON ↔ YAML")
        , el [ width fill ] none
        , Input.button
            [ Border.rounded 12
            , paddingXY 12 8
            , Background.color (onDark model (rgba 0.9 0.92 0.96 0.4))
            ]
            { onPress = Just ToggleDirection
            , label =
                text <|
                    case model.direction of
                        JsonToYaml -> "Mode: JSON → YAML"
                        YamlToJson -> "Mode: YAML → JSON"
            }
        , Input.button
            [ Border.rounded 12
            , paddingXY 12 8
            , Background.color (onDark model (rgba 0.9 0.92 0.96 0.4))
            ]
            { onPress = Just ToggleTheme
            , label = text (if model.dark then "Theme: Dark" else "Theme: Light")
            }
        ]


converterArea : Model -> Element Msg
converterArea model =
    let
        leftInfo =
            case model.direction of
                JsonToYaml ->
                    { title = "JSON Input", value = model.jsonInput, update = UpdateJson }

                YamlToJson ->
                    { title = "YAML Input", value = model.yamlInput, update = UpdateYaml }

        rightTitle =
            case model.direction of
                JsonToYaml ->
                    "YAML Output"

                YamlToJson ->
                    "JSON Output"
    in
    column [ width fill, spacing 16 ]
        [ row [ width fill, spacing 16 ]
            [ panel model leftInfo.title (Just leftInfo.update) leftInfo.value True
            , panel model rightTitle Nothing model.output False
            ]
        , row [ spacing 12 ]
            [ primaryButton model "Convert" DoConvert
            , secondaryButton model "Copy result" CopyOutput
            ]
        , case model.errorMsg of
            Nothing ->
                none

            Just e ->
                el
                    [ Font.color (rgb255 255 120 120)
                    , Background.color (onDark model (rgba 1.0 0.9 0.9 0.15))
                    , Border.rounded 12
                    , padding 12
                    ]
                    (text e)
        ]


panel :
    Model
    -> String
    -> Maybe (String -> Msg)
    -> String
    -> Bool
    -> Element Msg
panel model title toMsg value isEditable =
    column
        [ width fill
        , height (px 420)
        , spacing 8
        , Border.width 1
        , Border.rounded 16
        , Border.color (onDark model (rgba 1 1 1 0.15))
        , Background.color (onDark model (rgba 0.96 0.965 0.98 0.1))
        , padding 12
        ]
        [ row [ spacing 8, width fill ]
            [ el [ Font.bold ] (text title)
            , el [ width fill ] none
            ]
        , el [ width fill, height fill ] <|
            if isEditable then
                Input.multiline
                    [ width fill
                    , height fill
                    , padding 12
                    , Background.color (onDark model (rgba 1 1 1 0.06))
                    , Border.rounded 12
                    , Font.family [ Font.monospace ]
                    , Font.size 14
                    ]
                    { onChange = Maybe.withDefault (\_ -> Debug.todo "unreachable") toMsg
                    , text = value
                    , placeholder = Nothing
                    , label = Input.labelHidden title
                    , spellcheck = False
                    }

            else
                el
                    [ width fill
                    , height fill
                    , padding 12
                    , Background.color (onDark model (rgba 1 1 1 0.06))
                    , Border.rounded 12
                    , Element.scrollbarY
                    , Font.family [ Font.monospace ]
                    , Font.size 14
                    ]
                    (text value)
        ]


primaryButton : Model -> String -> Msg -> Element Msg
primaryButton model label_ msg_ =
    Input.button
        [ Border.rounded 12
        , paddingXY 16 10
        , Background.gradient
            { angle = pi / 12
            , steps =
                [ rgba 0.47 0.51 1.0 0.9
                , rgba 0.63 0.71 1.0 0.9
                ]
            }
        , Font.color (rgb255 255 255 255)
        , Font.semiBold
        ]
        { onPress = Just msg_, label = text label_ }


secondaryButton : Model -> String -> Msg -> Element Msg
secondaryButton model label_ msg_ =
    Input.button
        [ Border.rounded 12
        , paddingXY 16 10
        , Background.color (onDark model (rgba 0.9 0.92 1.0 0.2))
        ]
        { onPress = Just msg_, label = text label_ }


-- THEME HELPERS

themeBody : Bool -> List (Attribute msg)
themeBody dark =
    [ Background.color (if dark then rgb255 18 20 26 else rgb255 250 251 253)
    , Font.color (if dark then rgb255 235 238 245 else rgb255 35 38 46)
    , Font.family [ Font.typeface "Inter", Font.sansSerif ]
    ]


onDark : Model -> Color -> Color
onDark model c =
    if model.dark then
        c
    else
        -- ライトモードでは同じ色をそのまま使う
        c
