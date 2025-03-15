@tool
class_name Fact extends Resource


## The unique ID of the Fact. It is unique within the scope of the Parley plugin
## Example: 1
@export var id: int


## The unique name of the Fact.
## Example: "jonny_gave_coffee"
@export var name: String


## The ref script of the Fact.
## Example: "res://facts/jonny_gave_coffee_fact.gd"
@export var ref: Resource


func _init(p_id: int = 0, p_name: String = "", p_ref: Resource = null) -> void:
	id = p_id
	name = p_name
	ref = p_ref
