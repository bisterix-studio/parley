---
description: |
  Register an Action
---

Actions are resources in Parley used to execute defined functionality during the
running of a Dialogue Sequence. For example, an Action could contain
functionality to: emit a signal, register a journal entry, or update state.

Actions are stored in an action store which can be configured in the Parley
settings.

In this guide, we will create a action that can be used to create an Action Node
in the corresponding [create an Action Node guide](./create-action-node.md).

## Pre-requisites

- Ensure you have familiarised yourself with the
  [Action Node](../nodes/action-node.md) docs.
- Parley is [installed](./installation.md) and running in your Godot Editor.
- You have created a basic Dialogue Sequence before. Consult the
  [getting started guide](./create-dialogue-sequence.md) for more info.

## Instructions

![Register an Action](../../../www/static/docs/register-action/register-action.gif)

> [info]: it is assumed that the default Parley settings are used for the fact
> store and it is stored at: `res://facts/fact_store_main.tres`. You can find
> more information on changing the default Parley settings
> [here](../reference/parley-settings.md).

- Create an Action script (ensure that it extends the `ParleyActionInterface`
  class) at: `res://actions/advance_time_action.gd`

```gdscript
extends ParleyActionInterface

func execute(_ctx: Dictionary, values: Array) -> int:
	print("Advancing time by %s" % [values[0]])
	return OK
```

1. Open up the `ParleyStores` dock in the Godot Editor and click `Add Action`.
2. Give your new action an ID. In our example, we use: `main:advance_time`.
3. Give your new action a name. In our example, we use: `Advance Time`.
4. Link your created action script with the Action using the resource inspector
   (labelled `Ref`).

> [tip]: You can use the resource editors in `ParleyStores` to quickly navigate
> to the relevant resource for editing. You can also add resources using the
> resource editor dropdown field instead of dragging.

5. You should now see that the Action is available in the Action node dropdown
   options. Select `Advance Time` in the options to associate it with the
   selected Action Node.
6. Test out your new Action within the Dialogue Sequence by clicking the Test
   Dialogue Sequence from start button.
