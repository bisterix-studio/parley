@tool

class_name StartNodeAst extends NodeAst


## Create a new instance of a Start Node AST.
## Example: StartNodeAst.new("1", Vector2.ZERO)
func _init(p_id: String = "", p_position: Vector2 = Vector2.ZERO) -> void:
	type = DialogueAst.Type.START
	id = p_id
	position = p_position


static func get_colour() -> Color:
	return Color("#2f647a")
