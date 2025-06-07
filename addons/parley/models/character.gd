# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

@tool
class_name ParleyCharacter extends Resource

# TODO: maybe have this as a String
## The Unique ID of the Character. It is unique within the scope Parley plugin
## Example: "main:carol"
@export var id: String


## The Name of the Character.
## Example: "Carol"
@export var name: String


func _init(p_id: String = "", p_name: String = "") -> void:
	id = p_id
	name = p_name
