# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

@tool
class_name ParleyAction extends Resource


## The unique ID of the Action. It is unique within the scope of the Parley plugin
## Example: "1"
@export var id: String


## The unique name of the Action.
## Example: "Advance Time"
@export var name: String


## The ref action script of the Action.
## Example: "res://actions/advance_time_action.gd"
@export var ref: Resource


func _init(p_id: String = "", p_name: String = "", p_ref: Resource = null) -> void:
	id = p_id
	name = p_name
	ref = p_ref
