# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

@tool

class_name ParleyGroupNodeAst extends ParleyNodeAst


const default_group_colour: Color = Color("#111a2b")


## The name of the Group Node AST
@export var name: String = ""


## The node IDs associated with the Group Node AST
@export var node_ids: Array = []


## The colour of the Group Node AST
@export var colour: Color = default_group_colour


## The size of the Group Node AST
@export var size: Vector2 = Vector2(350, 350)


## Create a new instance of a Group Node AST.
## Example: ParleyGroupNodeAst.new("1", Vector2.ZERO, "Clues", Color("#bfc77f"))
func _init(p_id: String = "", p_position: Vector2 = Vector2.ZERO, p_name: String = "", p_node_ids: Array = [], p_colour: Color = default_group_colour, p_size: Vector2 = Vector2(350, 350)) -> void:
	type = ParleyDialogueSequenceAst.Type.GROUP
	id = p_id
	position = p_position
	name = p_name
	node_ids = p_node_ids
	colour = p_colour
	size = p_size


static func get_colour() -> Color:
	return default_group_colour
