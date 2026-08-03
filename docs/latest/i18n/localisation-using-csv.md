---
description: |
  Localisation using CSV files
---

Parley supports localisation using CSV files and aims to follow the Godot
guidance described
[here](https://docs.godotengine.org/en/stable/tutorials/i18n/localization_using_spreadsheets.html).

With Parley, users can both import and export CSV files to manage
internationalisation. This can be done via the `Translations` menu in the Parley
Editor.

In CSV mode, no context will be provided to the inbuilt `tr` function and as
such, the translation identifier provided becomes very important. Translation
CSV files can be broken down into two main components:

## 1. Translation ID

This is used to identify the text to translate for a Node and is passed to the
inbuilt Godot `tr` function. It is inferred as follows:

1. The `text_translation_key` field on the Node. This can be set using the
   Parley Node Editor. If present and populated on the Node, this will be used.
2. If the `text_translation_key` is not present or empty, then the Node `text`
   field on the Node is used as the translation key.

As an example, let's say we have the following nodes:

```json
{
  "nodes": [
    {
      "id": "node:1",
      "text": "I have a coffee.",
      "text_translation_key": ""
      // ...
    },
    {
      "id": "node:2",
      "text": "Give to Alice.",
      "text_translation_key": "GIVE_TO_ALICE"
    }
    // ...
  ]
  // ...
}
```

In the example above, the Translation ID would be:

- `node:1`: `I have a coffee.`
- `node:2`: `GIVE_TO_ALICE`

A corresponding CSV file (for a default header key and `en` project locale)
would look like the following:

```csv
keys,en
I have a coffee.,I have a coffee.
GIVE_TO_ALICE,Give to Alice.
```

> [tip]: By default, translation keys for Nodes will not be set and creating
> them for every Node in a Dialogue Sequence can be a pain. However, this is
> easily rectified by clicking the `Translations` ->
> `Generate Text Translation Keys...` button in the Parley plugin view. This
> will generate a text Translation Key for every Dialogue or Dialogue Option
> Node that doesn't have a populated Text Translation Key in the Dialogue
> Sequence.

## 2. Project locale translation value

This is equivalent to the `text` field of the Dialogue and Dialogue Option Node
and matches the project locale value within translations. This is always
included in imports and exports and is always used as a fallback when no
translation is available.

As an example, let's say we have the following nodes:

```json
{
  "nodes": [
    {
      "id": "node:1",
      "text": "I have a coffee.",
      "text_translation_key": ""
      // ...
    },
    {
      "id": "node:2",
      "text": "Give to Alice.",
      "text_translation_key": "GIVE_TO_ALICE"
    }
    // ...
  ]
  // ...
}
```

In the example above, the values are:

- `node:1`: `I have a coffee.`
- `node:2`: `Give to Alice.`

A corresponding CSV file (with an `en` project locale) would look like the
following:

```csv
keys,en
I have a coffee.,I have a coffee.
GIVE_TO_ALICE,Give to Alice.
```
