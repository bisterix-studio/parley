# How-To create a End Node

<!-- TODO: add Parley examples folder -->

An End Node defines the end of the Dialogue Sequence. Although Dialogue
Sequences do not require the presence of End Nodes to end a running Dialogue
Sequence, it is recommended to do so to make it clear to the Dialogue Sequence
writer that reaching this node ends the currently open dialogue. You can find
all sorts of Dialogue Sequence examples in the Parley `examples` folder.

## Pre-requisites

- Ensure you have familiarised yourself with the
  [End Node](../nodes/end_node.md) docs.

- Parley is installed and running in your Godot Editor.

- You have created a basic Dialogue Sequence before. Consult the other
  [How-To Guides](./how_to_add_dialogue_sequence.md) for more info.

## Instructions

![How-To create a End Node](./images/how_to_create_end_node/how_to_create_end_node.gif)

- Create a End Node using the `Insert` dropdown.

- Click on the created End Node in the graph view to open up the End Node
  Editor.

- Click the `Save` button in the Parley editor and there we have it! Our first
  End Node.

- Now connect this Node up with other Nodes to terminate the Dialogue Sequence
  and ensure it can be ended when this node is reached.

- You can test out your Dialogue Sequence by clicking the Test Dialogue Sequence
  from beginning button.
