# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

@tool
class_name ParleyActionNodeAst extends ParleyNodeAst


## The different actions available for the Dialogue AST
enum ActionType {
	SCRIPT
}


## The description of the Action Node AST.
## Example: "Player discovered clue 1"
@export var description: String


## The action type of the Action Node AST.
## Example: ActionType.SCRIPT
@export var action_type: ActionType


## The action script reference of the Action Node AST.
## Example: "res://actions/advance_time_action.gd"
@export var action_script_ref: String


## The values to send with the signal for the Action Node AST.
## Example: ["Clue1"]
@export var values: Array


## Create a new instance of a Action Node AST.
## Example: ParleyActionNodeAst.new("1", Vector2.ZERO, "Description")
func _init(
	p_id: String = "",
	p_position: Vector2 = Vector2.ZERO,
	p_description: String = "",
	p_action_type: ActionType = ActionType.SCRIPT,
	p_action_script_ref: String = "",
	p_values: Array = []
) -> void:
	type = ParleyDialogueSequenceAst.Type.ACTION
	id = p_id
	position = p_position
	description = p_description
	action_type = p_action_type
	action_script_ref = p_action_script_ref
	values = p_values


## Update an Action Node AST.
## Example: node.update("Description", ActionType.SCRIPT, "res://actions/advance_time_action.gd", [])
func update(p_description: String, p_action_type: ActionType, p_action_script_ref: String, p_values: Array) -> void:
	description = p_description
	action_type = p_action_type
	action_script_ref = p_action_script_ref
	values = p_values


## Convert this resource into a Dictionary for storage
func to_dict() -> Dictionary:
	var node_dict: Dictionary = inst_to_dict(self)
	var _at_path_discarded: bool = node_dict.erase('@path')
	var _sub_path_discarded: bool = node_dict.erase('@subpath')
	node_dict['action_type'] = str(ActionType.find_key(node_dict['action_type']))
	node_dict['type'] = str(ParleyDialogueSequenceAst.Type.find_key(node_dict['type']))
	return node_dict


## Get action type name for Action Node AST type
## Example: ParleyActionNodeAst.get_action_type_name(ActionType.SCRIPT)
static func get_action_type_name(_action_type: ActionType) -> String:
	var key: String = ActionType.keys()[_action_type]
	return key.capitalize()


## Get action type for Action Node AST name
## Example: ParleyActionNodeAst.get_action_type("Script")
static func get_action_type(name: String) -> ActionType:
	return ActionType[name.to_upper()]


static func get_colour() -> Color:
	return Color("#913b3f")
