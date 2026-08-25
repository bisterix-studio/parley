---
description: |
  Parley settings
---

Parley supports the following settings should you want to tweak some of the
default behaviours.

To access all the Parley settings, open up the Godot settings: `Project` ->
`Project Settings` and filter by: `parley`:

![parley-settings](../../../www/static/docs/reference/parley-settings.png)

## Stores

### Action Store Path

Defines the path to the Action Store resource that is used to store actions. The
resource extends resource type: `ParleyActionStore`.

> [warn]: This path must be valid in order for Parley to function properly.

Setting path: `parley/stores/action_store_path`

Default: `res://actions/action_store.tres`

### Fact Store Path

Defines the path to the Fact Store resource that is used to store facts. The
resource extends resource type: `ParleyFactStore`.

> [warn]: This path must be valid in order for Parley to function properly.

Setting path: `parley/stores/fact_store_path`

Default: `res://facts/fact_store.tres`

### Character Store Path

Defines the path to the Character Store resource that is used to store
characters. The resource extends resource type: `ParleyCharacterStore`.

> [warn]: This path must be valid in order for Parley to function properly.

Setting path: `parley/stores/character_store_path`

Default: `res://characters/character_store.tres`

## Dialogue

### Dialogue Balloon Path

Defines the path to the default Dialogue balloon that is used to render the
dialogue when testing and running Dialogue Sequences.

Setting path: `parley/dialogue/dialogue_balloon_path`

Default: `res://addons/parley/components/default_balloon.tscn`

## Internationalisation

### Translation Mode

Defines the translation mode to determine how to find and interpret
translations. It can be one of several values:

- `Auto` - The Translation Mode will be inferred from translations present in
  the project. Only `CSV` or `PO` Translation Modes can be inferred. This is the
  default behaviour.
- `PO` -
  [Godot PO files](https://docs.godotengine.org/en/stable/tutorials/i18n/localization_using_gettext.html)
  will be used to find and interpret translations.
- `CSV` -
  [CSV files](https://docs.godotengine.org/en/stable/tutorials/i18n/localization_using_spreadsheets.html)
  will be used to find and interpret translations.
- `Off` - No internationalisation will be applied.

More information about internationalisation support in Parley can be found
[here](../i18n/index.md).

Setting path: `parley/translations/mode`

Default: `PO`

### CSV Header Key

Defines the CSV header key that is used in CSV translation exports and imports.

More information about internationalisation support in Parley can be found
[here](../i18n/index.md).

Setting path: `parley/translations/csv_header_key`

Default: `keys`

## Testing

### Test Scene Path

Defines the path to the default test scene that is rendered when testing
Dialogue Sequences.

Setting path: `parley/test_dialogue_sequence/test_scene_path`

Default: `res://addons/parley/views/test_dialogue_sequence_scene.tscn`


## Effects

### Typewriter Effect

When on this will enable a typewriter effect for dialogue text. This effect 
gradually reveals the dialogue text over time.

Default: Off

### Typewriter Effect Time Between Characters Revealed in seconds

When using typewriter effect, this controls how fast the characters will be 
revealed in the dialogue.

Default: 0.05

### Speech Sound Effect

This effect is used to play sounds as the text is shown. If used in conjuction 
with Typewriter Effect, the speech sound will attempt to synchronize with the 
timing of the Typewriter Effect.

Default: Off


### Speech Sound Audio Stream Path

When using speech sound effect, this should point to the audio stream you 
would like the effect to use. This can be changed to different sounds, but 
also could be used for other audio stream types such as AudioStreamRandomizer 
or AudioStreamGenerator.

Default: res://addons/parley/assets/speech_sound_stream.tres


### Minimum Delay Between Speech Sounds in seconds

When using speech sound effect, this is the minimum time interval between
sound effects being played. The speech effect tries to synchronize with the
typewriter effect if it is also enabled. If the typewriter effect is very fast
then the speech sound will also get triggered very fast. This value is to 
prevent accidentaly polyphony with multiple speech sound effects overlapping.
If the typewriter effect is not enabled this is the time interval used between
speech effects being played.

Default: 0.1


### Maximum Speech Sounds Effect Time in seconds

When using speech sound effect, and not using typewriter effect, this is the
duration for which the entire effect will run.

Default: 5.0
