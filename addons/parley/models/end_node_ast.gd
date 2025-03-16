@tool

# TODO: prefix with Parley
class_name EndNodeAst extends NodeAst


## Create a new instance of a End Node AST.
## Example: EndNodeAst.new("1", Vector2.ZERO)
func _init(p_id: String = "", p_position: Vector2 = Vector2.ZERO) -> void:
	type = DialogueAst.Type.END
	id = p_id
	position = p_position


static func get_colour() -> Color:
	return Color("#5b4e90")
