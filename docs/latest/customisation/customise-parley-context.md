---
description: |
  Customise the Parley Context
---

When running Dialogue Sequences, Parley defines a base context that is passed
around throughout the processing of the Dialogue Sequence. This holds things
like runtime state or utilities (e.g. database accessors, signal buses etc).
These can be accessed and used during the Dialogue Sequence processing (e.g.
within Action scripts or Fact definitions) and provide a powerful means of
enhancing the functionality of your Dialogue Sequences.

When developing a game, it is likely that you might want to extend this context
to attach your game-specific pieces of data or utilities. In the majority of
cases, this will work out of the box. However, to access these pieces of data
from Action scripts or Fact definitions, one must define them in a specific way
to avoid type errors (without compromising type-safety).

## Prerequisites

- Parley is [installed](../getting-started/installation.md) and running in your
  Godot Editor.
- You have created a basic Dialogue Sequence before. Consult the
  [Getting Started guide](../getting-started/create-dialogue-sequence.md) for
  more info.

## Instructions

In this example, we will create a Fact that uses a custom context.

> [info]: It is assumed that the default Parley settings are used for the Fact
> Store and it is stored at: `res://facts/fact_store_main.tres`. Ensure you have
> also familiarised yourself with the
> [Condition Node](../nodes/condition-node.md) docs.

1. Create a custom context that extends `ParleyContext`. In our example, we call
   this `CustomContext`, this file can be placed anywhere within your game code.
   It contains some custom data and a log function:

```gdscript Custom context
class_name CustomContext extends ParleyContext


var custom_data: String


func _init(
	p_dialogue_sequence_ast: ParleyDialogueSequenceAst = ParleyDialogueSequenceAst.new(),
	data: Dictionary = {},
	p_custom_data: String = ""
) -> void:
	dialogue_sequence_ast = p_dialogue_sequence_ast
	p_data = data
	custom_data = p_custom_data


class log:
	static func info(message: String, data: Dictionary = {}) -> void:
		var json: Dictionary = {'message': message}
		json.merge(data, false)
		print(JSON.stringify(json))
```

2. Create a Fact script (ensure that it extends the `ParleyFactInterface` class)
   at: `res://facts/alice_gave_coffee_fact.gd`

```gdscript Evaluate Fact
extends ParleyFactInterface

func evaluate(p_ctx: ParleyContext, _values: Array) -> bool:
	var ctx: CustomContext = p_ctx
	ctx.log.info('Some useful logging')
	# Note, you can return any value here, it doesn't
	# necessarily have to be a bool
	return true
```

3. Follow the rest of the Fact registration
   [guide](../getting-started/register-fact.md) from step 2 onwards to complete
   the rest of the Fact setup.
4. Follow the run Dialogue Sequence
   [guide](../getting-started/run-dialogue-sequence.md) with the following tweak
   when instantiating the custom context:

```gdscript Instantiate the Custom Context
var ctx: CustomContext

func _ready() -> void:
	# Trigger the start of the Dialogue Sequence processing using the Parley autoload
	# Define the new context before running here
	ctx = CustomContext.new(basic_dialogue, {}, 'level_1')
	var _result: Node = Parley.run_dialogue(ctx, basic_dialogue)
```
