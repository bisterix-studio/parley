@tool
# TODO: prefix with Parley
class_name Action extends Resource


# TODO: make a string
## The unique ID of the Action. It is unique within the scope of the Parley plugin
## Example: "1"
@export var id: String


## The unique name of the Action.
## Example: "advance_time"
@export var name: String


## The ref action script of the Action.
## Example: "res://actions/advance_time_action.gd"
@export var ref: Resource


func _init(p_id: String = "", p_name: String = "", p_ref: Resource = null) -> void:
	id = p_id
	name = p_name
	ref = p_ref
