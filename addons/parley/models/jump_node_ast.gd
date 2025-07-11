# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

@tool
class_name ParleyJumpNodeAst extends ParleyNodeAst


## The Dialogue Sequence AST to jump to.
## Example: "uid://acb123def56gh"
@export var dialogue_sequence_ast_ref: String


## Create a new instance of a Action Node AST.
## Example: ParleyActionNodeAst.new("1", Vector2.ZERO, "Description")
func _init(
	p_id: String = "",
	p_position: Vector2 = Vector2.ZERO,
	p_dialogue_sequence_ast_ref: String = "",
) -> void:
	type = ParleyDialogueSequenceAst.Type.JUMP
	id = p_id
	position = p_position
	dialogue_sequence_ast_ref = p_dialogue_sequence_ast_ref


static func get_colour() -> Color:
	return Color("#a94a78")
