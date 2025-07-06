---
description: |
  Create a Dialogue Sequence
---

A Dialogue Sequence is a conversational structure for a branching dialogue
between multiple characters for a particular scene or scenes. They can include:

- The raw dialogue itself
- Options for the player to select
- Conditions to only render dialogue in certain situations
- Actions that trigger upon events within Dialogue Sequence.
- And much much more!

To find out more about the concepts behind Dialogue Sequences, please click
[here](../concepts/architecture.md)

For more information on creating nodes within your Dialogue Sequences, please
refer to the following guides:

- [Create a Dialogue Node](./create-dialogue-node.md)
- [Create a Dialogue Option Node](./create-dialogue-option-node.md)
- [Create a Condition Node](./create-condition-node.md)
- [Create a Match Node](./create-match-node.md)
- [Create an Action Node](./create-action-node.md)
- [Create a Start Node](./create-start-node.md)
- [Create an End Node](./create-end-node.md)
- [Create a Group Node](./create-group-node.md)

## Prerequisites

- Ensure you have familiarised yourself with the
  [key Parley concepts](../concepts/architecture.md).
- Parley is [installed](./installation.md) and running in your Godot Editor.

## Instructions

![create-dialogue-sequence](../../../www/static/docs/create-dialogue-sequence/create-dialogue-sequence.gif)

> [tip]: If you'd like to access and follow along using the supporting video
> instead, please find the original mp4
> [here](https://github.com/bisterix-studio/parley/blob/main/www/static/docs/create-dialogue-sequence/create-dialogue-sequence.mp4).

1. Navigate to the main Parley view by clicking `Parley` at the top of the
   editor.
2. In the Parley view, click `File` and select `New Dialogue Sequence...` to
   open the `New Dialogue` modal.
3. Set the path of where you want to store your Dialogue Sequence. In our
   example, we set this to: `res://dialogue_sequences/my_dialogue.ds`

> [info]: The `.ds` file extension is a special type of extension created by
> Parley to differentiate Dialogue Sequence resources from others. It uses
> `JSON` syntax.

4. Click `Create` to create the Dialogue Sequence.
5. Now let's start populating the Dialogue Sequence with Nodes! We start by
   creating a Start Node, by selecting `Insert` -> `Start` in the main Parley
   view.
6. Before, we create Dialogue Nodes, create two characters in the Character
   Store by navigating to the `Character` tab in the `ParleyStores` dock. In our
   example, we call them `Alice` and `Bob`.
7. Save the created characters in the Character store by clicking the save
   button in the ParleyStores dock.
8. Then, create some Dialogue Nodes and connect up with Edges using the Node
   slots in the main Parley view.
9. Finally, create an End Node to complete our simple Dialogue Sequence, by
   selecting `Insert` -> `End` in the main Parley view.
10. Save the Dialogue Sequence by clicking the save button in the main Parley
    view.
11. You can test out your Dialogue Sequence by clicking the Test Dialogue
    Sequence From Start Button.
