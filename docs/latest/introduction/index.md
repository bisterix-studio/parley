---
description: |
  Parley is an addon for Godot 4.4+ that provides a
  graph-based dialogue manager for easy writing, testing, and running of Dialogue
  Sequences at scale and is designed to be used by game writers and developers
  alike.

  Write your Dialogue Sequences by defining the graph for your Dialogue Sequence
  which are backed by a well-defined Dialogue AST for easy management and
  integration within your game.
---

Parley is an addon for [Godot 4.4+](https://godotengine.org/) that provides a
graph-based dialogue manager for easy writing, testing, and running of Dialogue
Sequences at scale and is designed to be used by game writers and developers
alike.

Write your Dialogue Sequences by defining the graph for your Dialogue Sequence
which are backed by a well-defined Dialogue AST for easy management and
integration within your game.

You can install it via the
[Asset Library](https://godotengine.org/asset-library/asset/4132) or
[downloading a copy](https://github.com/bisterix-studio/parley/archive/refs/heads/main.zip)
from GitHub.

Some stand out features:

- An easy-to-use and well-defined Graph Editor
- A wide variety of Nodes for maximum flexibility and creativity:
  - [Dialogue](../nodes/dialogue-node.md)
  - [Dialogue Option](../nodes/dialogue-option-node.md)
  - [Condition](../nodes/condition-node.md)
  - [Match](../nodes/match-node.md)
  - [Action](../nodes/action-node.md)
  - [Jump](../nodes/jump-node.md)
  - [Group](../nodes/group-node.md)
  - [Start](../nodes/start-node.md)
  - [End](../nodes/end-node.md)
- Creation of connections between Nodes to easily see the flow of your dialogue
  sequence
- Easy testing of your dialogue at any stage in the sequence
- Well-defined Dialogue AST for easy review and management of Dialogue Sequences
- Internationalization (i18n) support for both CSV and GNUText
- Character Store for management of characters in Dialogue and Dialogue Options
- Action Store for management of actions for use with Action Nodes
- Fact Store for management of facts for use with Condition and Match Nodes
- An out of the box dialogue balloon to get started straight away
- Easy management of your Dialogue Sequences, including Node filtering
- Export your Dialogue passages to CSV

![parley](../../../www/static/docs/parley.png)

## Upcoming Features

Here are some key features on the Parley horizon. We are always open to new
ideas, please don't hesitate to
[get-in-touch](https://github.com/bisterix-studio/parley/issues).

- Dialogue text expressions
- Custom Action Nodes

## License

Parley is 100% free and open-source, under the MIT licence.
[The license is distributed with Parley and can be found in the `addons/parley` folder](https://github.com/bisterix-studio/parley/blob/main/addons/parley/LICENSE).

This package is [Treeware](https://treeware.earth). If you use it in production,
then we ask that you
[**buy the world a tree**](https://plant.treeware.earth/bisterix-studio/parley)
to thank us for our work. By contributing to the Treeware forest you’ll be
creating employment for local families and restoring wildlife habitats.

## Contributions

[Contributions](https://github.com/bisterix-studio/parley/blob/main/CONTRIBUTING.md),
issues and feature requests are very welcome. If you are using this package and
fixed a bug for yourself, please consider submitting a PR!

<p align="center">
  <a href="https://github.com/bisterix-studio/parley/graphs/contributors">
    <img src="https://contrib.rocks/image?repo=bisterix-studio/parley&columns=8" />
  </a>
</p>
