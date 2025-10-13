---
description: |
  Parley supports multiple ways of handling translations for your game: using CSV files and using GNU gettext.
---

## Text translations

Parley supports multiple ways of handling translations for your game:

- Using [CSV files](../internationalisation/localisation-using-csv.md). This
  corresponds to `CSV` translation mode.
- Using [GNU gettext](../internationalisation/localisation-using-gettext.md).
  This corresponds to `PO` translation mode.

By default, Parley will detect the current translation mode and attempt to
translate defined text in using the unbuilt Godot `tr` function for the
following nodes:

- [Dialogue Node](../nodes/dialogue-node.md)
- [Dialogue Option Node](../nodes/dialogue-option-node.md)

> [tip]: You can select the modes that Parley will run under and also also turn
> off translation support in Parley in the Parley project
> [settings](../reference/parley-settings.md).

If Parley is unable to detect the current translation mode, it will default to
CSV mode.

Each translation mode translates the text slightly differently. You can find
more information in the docs for each:

- Using [CSV files](../internationalisation/localisation-using-csv.md).
- Using [GNU gettext](../internationalisation/localisation-using-gettext.md).

## Character translations

Parley makes the assumption that character translations are handled separately
to Parley because they are used in more than just dialogue. As a result, the
default Parley balloon try and translate the character name directly with a
specific context of `DIALOGUE` to avoid any unexpected clashes.
