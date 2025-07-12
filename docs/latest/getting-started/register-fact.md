---
description: |
  Register a Fact
---

Facts are resources in Parley used by Condition and Match Nodes for comparisons
within the currently running game. For example, one might want to display
different dialogue depending on whether a condition check is passed or not (e.g.
whether Alice gave a coffee or not).

Facts are stored in a Fact Store which can be configured in the Parley settings.

In this guide, we will create a Fact that can be used to create a Condition Node
in the corresponding
[create a Condition Node guide](./create-condition-node.md).

## Prerequisites

- Ensure you have familiarised yourself with the
  [Condition Node](../nodes/condition-node.md) docs.
- Parley is [installed](./installation.md) and running in your Godot Editor.
- You have created a basic Dialogue Sequence before. Consult the
  [Getting Started guide](./create-dialogue-sequence.md) for more info.

## Instructions

> **Note:** it is assumed that the default Parley settings are used for the Fact
> Store and it is stored at: `res://facts/fact_store_main.tres`

1. Create a Fact script (ensure that it extends the `ParleyFactInterface` class)
   at: `res://facts/alice_gave_coffee_fact.gd`

```gdscript
extends ParleyFactInterface

func execute(ctx: ParleyContext, _values: Array) -> bool:
	print('Did Alice give coffee?')
	# Note, you can return any value here, it doesn't
	# necessarily have to be a bool
	return true
```

2. [OPTIONAL] If the return type of your Fact, is **not** of type `bool`, it is
   recommended to return well-known values of the Fact (for example, when using
   a [Match Node](../nodes/match-node.md)). For example:

```gdscript
extends ParleyFactInterface

enum DifficultyLevel {
	EASY,
	NORMAL,
	HARD,
}

func execute(ctx: ParleyContext, _values: Array) -> int:
	return ctx.get('difficulty_level', DifficultyLevel.NORMAL)

func available_values() -> Array[DifficultyLevel]:
	return [
		DifficultyLevel.EASY,
		DifficultyLevel.NORMAL,
		DifficultyLevel.HARD,
	]
```

3. Open up the `ParleyStores` dock in the Godot Editor and open the `Fact` tab.
4. Click `Add Fact`.
5. Give your new Fact an ID. In our example, we use: `main:alice_gave_coffee`.
6. Give your new Fact a name. In our example, we use: `Alice gave coffee`.
7. Link your created Fact script with the Fact using the resource inspector
   (labelled `Ref`).

> [tip]: You can use the resource Editors in `ParleyStores` to quickly navigate
> to the relevant resource for editing. You can also add resources using the
> resource Editor dropdown field instead of dragging.

8. You should now see that the Fact is available in the Fact dropdown options in
   the Condition Node Editor. Select `Alice gave coffee` in the options to
   associate it with the selected Condition Node.
9. Test out your new Fact within the Dialogue Sequence by clicking the Test
   Dialogue Sequence From Start Button.
