---
description: |
  Localisation using GNU gettext
---

Parley supports localisation using GNU gettext (PO) files and aims to follow the
Godot guidance and info described
[here](https://docs.godotengine.org/en/stable/tutorials/i18n/localization_using_gettext.html).
This is especially useful if you want to support plurals and context in your
translations. However, it is a more complex format than CSV files.

With Parley, users use PO files to manage internationalisation. Information on
how to create and use PO files can be found
[here](https://docs.godotengine.org/en/stable/tutorials/i18n/localization_using_gettext.html#creating-the-po-template).

This approach in Parley can be broken down into two key components:

- `msgid` - this corresponds to the `text` value that is primarily used to
  identify the translation. E.g. the `text` field on the Dialogue or Dialogue
  Option Node.
- `msgctxt` - this corresponds to the Translation Key on the node. For example,
  the `text_translation_key` on a Dialogue Node.

> [info]: Please note, at the moment, Parley does not currently support adding
> notes for translators. However, this will be implemented in a future release.

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

This would be equivalent to the following POT file:

```txt
# node:1
msgid "I have a coffee."

# node:2
msgctxt "GIVE_TO_ALICE"
msgid "Give to Alice."
```

> [tip]: By default, translation keys for Nodes will not be set and creating
> them for every Node in a Dialogue Sequence can be a pain. However, this is
> easily rectified by clicking the `Translations` ->
> `Generate Text Translation Keys...` button in the Parley plugin view. This
> will generate a text Translation Key for every Dialogue or Dialogue Option
> Node that doesn't have a populated Text Translation Key in the Dialogue
> Sequence.

The POT file for the french translation (`fr.po`) would be:

```txt
# node:1
msgid "I have a coffee."
msgstr "Je prends un café."

# node:2
msgctxt "GIVE_TO_ALICE"
msgid "Give to Alice."
msgstr "Donnez-le à Alice."
```

When this POT file is registered in Godot via the
[defined mechanisms](https://docs.godotengine.org/en/stable/tutorials/i18n/localization_using_gettext.html)
and the locale is set to `fr`, then the displayed language would be French when
Parley is run.
