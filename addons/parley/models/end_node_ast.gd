# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

@tool
class_name ParleyEndNodeAst extends ParleyNodeAst


## Create a new instance of a End Node AST.
## Example: ParleyEndNodeAst.new("1", Vector2.ZERO)
func _init(p_id: String = "", p_position: Vector2 = Vector2.ZERO) -> void:
	type = ParleyDialogueSequenceAst.Type.END
	id = p_id
	position = p_position


static func get_colour() -> Color:
	return Color("#5b4e90")
