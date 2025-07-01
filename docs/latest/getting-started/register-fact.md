---
description: |
  Register a Fact
---

Facts are resources in Parley used by Condition and Match Nodes for comparisons
within the currently running game. For example, one might want to display
different dialogue depending on whether a condition check is passed or not (e.g.
whether Alice gave a coffee or not).

Facts are stored in a fact store which can be configured in the Parley settings.

In this guide, we will create a fact that can be used to create a Condition Node
in the corresponding
[create a Condition Node guide](./create-condition-node.md).

## Pre-requisites

- Ensure you have familiarised yourself with the
  [Condition Node](../nodes/condition-node.md) docs.
- Parley is [installed](./installation.md) and running in your Godot Editor.
- You have created a basic Dialogue Sequence before. Consult the
  [getting started guide](./create-dialogue-sequence.md) for more info.

## Instructions

> **Note:** it is assumed that the default Parley settings are used for the fact
> store and it is stored at: `res://facts/fact_store_main.tres`

1. Create a Fact script (ensure that it extends the `FactInterface` class) at:
   `res://facts/alice_gave_coffee_fact.gd`

```gdscript
extends FactInterface

func execute(ctx: Dictionary, _values: Array) -> bool:
	print('Did Alice give coffee?')
	# Note, you can return any value here, it doesn't
	# necessarily have to be a bool
	return true
```

2. [OPTIONAL] If the return type of your fact, is **not** of type `bool`, it is
   recommended to return well-known values of the fact (for example, when using
   a [Match Node](../nodes/match-node.md)). For example:

```gdscript
extends FactInterface

enum DifficultyLevel {
	EASY,
	NORMAL,
	HARD,
}

func execute(ctx: Dictionary, _values: Array) -> int:
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
5. Give your new fact an ID. In our example, we use: `main:alice_gave_coffee`.
6. Give your new fact a name. In our example, we use: `Alice gave coffee`.
7. Link your created fact script with the Fact using the resource inspector
   (labelled `Ref`).

> [tip]: You can use the resource editors in `ParleyStores` to quickly navigate
> to the relevant resource for editing. You can also add resources using the
> resource editor dropdown field instead of dragging.

8. You should now see that the Fact is available in the Fact dropdown options in
   the Condition node editor. Select `Alice gave coffee` in the options to
   associate it with the selected Condition node.
9. Test out your new Fact within the Dialogue Sequence by clicking the Test
   Dialogue Sequence from start button.
