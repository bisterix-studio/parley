@tool
class_name Character extends Resource


## The Unique ID of the Character. It is unique within the scope Parley plugin
## Example: 1
@export var id: int


## The Name of the Character.
## Example: "Billie"
@export var name: String


func _init(p_id: int = 0, p_name: String = "") -> void:
	id = p_id
	name = p_name
