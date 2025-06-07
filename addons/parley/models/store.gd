# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

@tool
class_name ParleyStore extends Resource


enum Type {
	Character,
	Fact,
	Action,
}


## The Unique ID of the Store AST.
## Example: "1"
@export var id: String = ""

func _init(_id: String = "") -> void:
	id = _id

## Convert this resource into a Dictionary for storage
func to_dict() -> Dictionary:
	return {
		'id': id,
		'ref': ParleyUtils.resource.get_uid(self),
	}

func _to_string() -> String:
	return "ParleyStore<%s>" % [str(to_dict())]
