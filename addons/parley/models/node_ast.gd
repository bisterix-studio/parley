@tool

# TODO: prefix with Parley
class_name NodeAst extends Resource


## The Unique ID of the Node AST. It is unique within the scope of the Dialogue AST
## Example: "1"
@export var id: String

# TODO: is there a circular dep issue for DialogueAst.Type here?
# Is this symptomatic of a wider problem perhaps?

## The type of the Node AST.
## Example: DialogueAst.Type.START
@export var type: DialogueAst.Type = DialogueAst.Type.UNKNOWN

## The position of the Node AST.
## Example: "(1, 2)"
@export var position: Vector2

func _init(p_id: String = "", p_position: Vector2 = Vector2.ZERO) -> void:
	id = p_id
	position = p_position


## Convert this resource into a Dictionary for storage
func to_dict() -> Dictionary:
	var node_dict: Dictionary = inst_to_dict(self)
	node_dict.erase('@path')
	node_dict.erase('@subpath')
	node_dict['type'] = str(DialogueAst.Type.find_key(node_dict['type']))
	return node_dict


func _to_string() -> String:
	return "NodeAst<%s>" % [str(to_dict())]


static func get_colour() -> Color:
	return Color("#7a2167")
