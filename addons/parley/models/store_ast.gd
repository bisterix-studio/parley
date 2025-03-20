@tool
# TODO: prefix with Parley
class_name StoreAst extends Resource

## The Unique ID of the Store AST.
## Example: "1"
@export var id: String = ""

func _init(_id: String = "") -> void:
	id = _id

## Convert this resource into a Dictionary for storage
func to_dict() -> Dictionary:
	return {
		'id': id,
		'ref': resource_path,
	}

func _to_string() -> String:
	return "StoreAst<%s>" % [str(to_dict())]
