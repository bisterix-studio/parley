---
description: |
  Parley provides a runtime instance that the developer can use to run Dialogue Sequences when the game is running.
---

Parley provides a runtime instance that the developer can use to run Dialogue
Sequences when the game is running. This is autoloaded as `Parley` upon
activation of the Parley plugin. It can be used to:

- [Start Dialogue Sequences.](#starting-a-dialogue-sequence)

## Starting a Dialogue Sequence

A Dialogue Sequence can be started using the Parley runtime as follows:

```gdscript
extends Node

const basic_dialogue: ParleyDialogueSequenceAst = preload("res://dialogue_sequences/my_dialogue.ds")

func _ready() -> void:
  # Trigger the start of the Dialogue Sequence processing using the Parley autoload
	var _result: Node = Parley.start_dialogue({}, basic_dialogue)
```

For a real example of starting a Dialogue Sequence, please see this
[guide](../getting-started/run-dialogue-sequence.md).

## Reference

### `start_dialogue`

`start_dialogue(ctx: Dictionary, dialogue_sequence_ast: ParleyDialogueSequenceAst, start_node: ParleyNodeAst = null) -> Node`

Parameters:

- **ctx** `Dictionary` - This is the current context object of the Dialogue
  Sequence. It is passed from Node to Node and can be used to hold non-global
  state that the Nodes can get access to.
- **dialogue_sequence_ast** `ParleyDialogueSequenceAst` - This is the Dialogue
  Sequence instance to process.
- **start_node** `ParleyNodeAst` - Default: `null` - This is the the Node to
  start the Dialogue Sequence from. This is useful when resuming an already
  started Dialogue Sequence. For example, loading a save game. If not defined,
  Parley will attempt to find the Start Node.

Returns the instantiated Dialogue Balloon that has been used to render the
running Dialogue Sequence. This can be controlled via the
[Parley settings](../reference/parley-settings.md).
