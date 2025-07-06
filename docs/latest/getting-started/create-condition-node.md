---
description: |
  Create a Condition Node
---

Condition Nodes can be used to conditionally direct users down different
dialogue branches or even conditionally render options. They are designed to be
infinitely nested in theory and you can find all sorts of Dialogue Sequence
examples in the Parley
[`examples`](https://github.com/bisterix-studio/parley/tree/main/examples)
folder.

## Prerequisites

- Ensure you have familiarised yourself with the
  [Condition Node](../nodes/condition-node.md) docs.
- Parley is [installed](./installation.md) and running in your Godot Editor.
- You have followed the [instructions](./register-fact.md) to add the relevant
  facts to the system.
- You have created a basic Dialogue Sequence before. Consult the
  [Getting Started guide](./create-dialogue-sequence.md) for more info.

## Instructions

![Create a Condition Node](../../../www/static/docs/create-condition-node/create-condition-node.gif)

1. Create a Condition Node using the `Insert` dropdown.
2. Click on the created Condition Node in the graph view to open up the
   Condition Node Editor.
3. Enter a high-level descriptive name for what the Condition Node represents.
   This is because it can be sometimes hard to work out what conditions are
   doing so the more info you can provide up front the better! In this example,
   we write: `Alice gave coffee`.
4. Now choose a Combiner for all of your conditions. Here we will choose `All`
   which means that all of the conditions have to pass in order for the
   Condition Node to be `true`.
5. Next up is to define the conditions for the Combiner. Click `Add Condition`.
   During the running of a Dialogue Sequence, each condition will be evaluated
   in turn and sent to the Combiner to calculate whether the Condition Node is
   truthy (or not). Note, you create more than one condition for the Combiner.
6. Select a Fact using the dropdown. In this case, we will select the
   `Alice gave coffee` Fact. Facts are manually defined scripts that execute
   when a condition is evaluated and return a value to be checked later in the
   condition.

> [tip]: You can click on the pencil icon to the right of the Fact to view the
> selected Fact in the Godot GDScript Editor and optionally edit it.

7. Next, choose an Operator. Here, we will use the `Equal` Operator. This will
   be used to compare the result of the Fact against a defined value (coming
   next!).
8. Finally, choose a value to compare with. Here we set the value to `true`.
   Please note, Parley does perform a basic level of coercion so in this case,
   this will be a GDScript `bool`.
9. Click the `Save` button in the Parley Editor and there we have it! Our first
   Condition Node. Now connect this Node up with other Nodes (here, we define a
   basic setup for each possible input and output of the Condition Node).
10. You can test out your Dialogue Sequence by clicking the Test Dialogue
    Sequence From Start Button.
