---
description: |
  Parley supports multiple ways of handling translations for your game: using CSV files and using GNU gettext.
---

Parley supports multiple ways of handling translations for your game:

- Using [CSV files](../internationalisation/localisation-using-csv.md)
- Using [GNU gettext](../internationalisation/localisation-using-gettext.md)

By default, Parley will detect the current translation mode and attempt to
translate defined text in using the unbuilt Godot `tr` function for the
following nodes:

- [Dialogue Node](../nodes/dialogue-node.md)
- [Dialogue Option Node](../nodes/dialogue-option-node.md)

> [tip]: You can select the modes that Parley will run under and also also turn
> off translation support in Parley in the Parley project
> [settings](../reference/parley-settings.md).

<!-- TODO: include information about characters -->
