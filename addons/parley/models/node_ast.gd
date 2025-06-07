# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

@tool

class_name ParleyNodeAst extends Resource


#region DEFS
## The Unique ID of the Node AST. It is unique within the scope of the Dialogue AST
## Example: "1"
@export var id: String: set = _set_id

# TODO: is there a circular dep issue for ParleyDialogueSequenceAst.Type here?
# Is this symptomatic of a wider problem perhaps?

## The type of the Node AST.
## Example: ParleyDialogueSequenceAst.Type.START
@export var type: ParleyDialogueSequenceAst.Type = ParleyDialogueSequenceAst.Type.UNKNOWN

## The position of the Node AST.
## Example: "(1, 2)"
@export var position: Vector2


const id_prefix: String = "node:"
#endregion


#region LIFECYCLE
func _init(_id: String = "", _position: Vector2 = Vector2.ZERO) -> void:
	id = _id
	position = _position
#endregion


#region SETTERS
func _set_id(new_id: String) -> void:
	# Once defined, id should be immutable
	if not id or id == id_prefix or not id.begins_with(id_prefix):
		id = new_id if new_id.begins_with(id_prefix) else "%s%s" % [id_prefix, new_id]
#endregion


#region UTILS
## Convert this resource into a Dictionary for storage
func to_dict() -> Dictionary:
	var node_dict: Dictionary = inst_to_dict(self)
	var _path_result: bool = node_dict.erase('@path')
	var _subpath_result: bool = node_dict.erase('@subpath')
	node_dict['type'] = str(ParleyDialogueSequenceAst.Type.find_key(node_dict['type']))
	return node_dict


func _to_string() -> String:
	return "ParleyNodeAst<%s>" % [str(to_dict())]


static func get_colour() -> Color:
	return Color("#7a2167")
#endregion
