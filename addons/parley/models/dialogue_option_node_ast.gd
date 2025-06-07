# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

@tool
class_name ParleyDialogueOptionNodeAst extends ParleyNodeAst


## The character of the Dialogue Option Node AST.
## Example: "Alice"
@export var character: String


## The text of the Dialogue Option Node AST.
## Example: "Slurp some coffee."
@export var text: String


## Create a new instance of a Dialogue Option Node AST.
## Example: ParleyDialogueOptionNodeAst.new("1", Vector2.ZERO, "Alice", "Slurp some coffee.")
func _init(
	p_id: String = "",
	p_position: Vector2 = Vector2.ZERO,
	p_character: String = "",
	p_text: String = ""
) -> void:
	type = ParleyDialogueSequenceAst.Type.DIALOGUE_OPTION
	id = p_id
	position = p_position
	character = p_character
	text = p_text


## Update a Dialogue Option Node AST.
## Example: node.update("Alice", "Slurp some coffee.")
func update(p_character: String, p_text: String) -> void:
	character = p_character
	text = p_text


static func get_colour() -> Color:
	return Color("#3268bf")


#region UTILS
func resolve_character() -> ParleyCharacter:
	return ParleyCharacterStore.resolve_character_ref(character)
#endregion
