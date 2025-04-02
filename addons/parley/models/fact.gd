@tool
# TODO: prefix with Parley
class_name Fact extends Resource

# TODO: make a string
## The unique ID of the Fact. It is unique within the scope of the Parley plugin
## Example: "1"
@export var id: String


## The unique name of the Fact.
## Example: "alice_gave_coffee"
@export var name: String


## The ref script of the Fact.
## Example: "res://facts/alice_gave_coffee_fact.gd"
@export var ref: Resource


func _init(p_id: String = "", p_name: String = "", p_ref: Resource = null) -> void:
	id = p_id
	name = p_name
	ref = p_ref
