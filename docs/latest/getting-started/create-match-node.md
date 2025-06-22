---
description: |
  Create a Match Node
---

<!-- TODO: add Parley examples folder -->

A Match Node is useful for selecting the next node based on the well-known value
of a variable or expression. You can find all sorts of Dialogue Sequence
examples in the Parley `examples` folder.

## Pre-requisites

- Ensure you have familiarised yourself with the
  [Match Node](../concepts/match-node.md) docs.
- Parley is installed and running in your Godot Editor.
- You have followed the [instructions](./register-fact.md) to add the relevant
  facts to the system. Make sure you create a fact with well-known values.
- You have created a basic Dialogue Sequence before. Consult the
  [getting started guide](./create-dialogue-sequence.md) for more info.

## Instructions

- Create a Match Node using the `Insert` dropdown:

![Create Match Node](../../../www/static/docs/create-match-node/create-match-node-button.png)

- Click on the created Match Node in the graph view to open up the Match Node
  Editor:

![Match Node Editor](../../../www/static/docs/create-match-node/match-node-editor.png)

- Enter a high-level descriptive name for what the Match Node represents. This
  is because it can be sometimes hard to work out what matches are doing so the
  more info you can provide up front the better!

![Match Node Editor Description](../../../www/static/docs/create-match-node/match-node-editor-description.png)

- Select a fact using the dropdown. In this case, we will select the
  `Snooker balls` fact. Facts are manually defined scripts that execute when a
  match is evaluated and return a value to be checked later in the match. These
  also define well-known values that are used to select against.

![Match Node Editor Select Fact](../../../www/static/docs/create-match-node/match-node-editor-select-fact.png)

- Now choose your cases you want to select against. Here we will choose all of
  the available cases including the fallback case. This means that even if we
  don't select on a case, the fallback will be chosen as the next path.

![Match Node Editor Cases](../../../www/static/docs/create-match-node/match-node-editor-cases.png)

- Click the `Save` button in the Parley editor and there we have it! Our first
  Match Node. Now connect this Node up with other Nodes (here, we define a basic
  setup for each possible input and output of the Match Node):

![Define other Nodes](../../../www/static/docs/create-match-node/define-other-nodes.png)

- You can test out your Dialogue Sequence by clicking the Test Dialogue Sequence
  from start button:

![Test Dialogue Sequence](../../../www/static/docs/create-match-node/test-dialogue-sequence.png)
