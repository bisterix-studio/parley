---
description: |
  Create a Dialogue Option Node
---

A Dialogue Node defines a series of options presented to the player within the
Dialogue Sequence. You can find all sorts of Dialogue Sequence examples in the
Parley
[`examples`](https://github.com/bisterix-studio/parley/tree/main/examples)
folder.

## Prerequisites

- Familiarise yourself with the
  [Dialogue Option Node](../nodes/dialogue-option-node.md) docs.
- Parley is [installed](./installation.md) and running in your Godot Editor.
- You have followed the [instructions](./register-character.md) to add the
  relevant characters to the system.
- You have created a basic Dialogue Sequence before. Consult the
  [Getting Started guide](./create-dialogue-sequence.md) for more info.

## Instructions

![Create a Dialogue Option Node](../../../www/static/docs/create-dialogue-option-node/create-dialogue-option-node.gif)

1. Create Dialogue Option Nodes using the `Insert` dropdown.
2. Click on each created Dialogue Node in the graph view to open up the Dialogue
   Node Editor.
3. Click the `Save` button in the Parley Editor and there we have it! Our first
   Dialogue Sequence with Dialogue Options.
4. Now connect these Nodes up with other Nodes to continue the Dialogue Sequence
   with your awesome game writing!
5. You can test out your Dialogue Sequence by clicking the Test Dialogue
   Sequence From Start Button.

> [tip]: The order of the Dialogue Options is determined by the vertical (or y)
> position of the Nodes in the Dialogue Sequence Graph Editor. Developers can
> therefore influence the order of Dialogue Options by swapping options around
> vertically in the Editor.
