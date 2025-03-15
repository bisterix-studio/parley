@tool

class_name DialogueNodeAst extends NodeAst


## The character of the Dialogue Node AST.
## Example: "Jonny"
@export var character: String


## The text of the Dialogue Node AST.
## Example: "I need some coffee."
@export var text: String


## Create a new instance of a Dialogue Node AST.
## Example: DialogueNodeAst.new("1", Vector2.ZERO, "Jonny", "I need some coffee.")
func _init(
	p_id: String = "",
	p_position: Vector2 = Vector2.ZERO,
	p_character: String = "",
	p_text: String = ""
) -> void:
	type = DialogueAst.Type.DIALOGUE
	id = p_id
	position = p_position
	character = p_character
	text = p_text


## Update a Dialogue Node AST.
## Example: node.update("Jonny", "I need some coffee.")
func update(p_character: String, p_text: String) -> void:
	character = p_character
	text = p_text


static func get_colour() -> Color:
	return Color("#266145")
