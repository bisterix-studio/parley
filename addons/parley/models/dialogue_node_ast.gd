# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

@tool
class_name ParleyDialogueNodeAst extends ParleyNodeAst


## The character of the Dialogue Node AST.
## Example: "Alice"
@export var character: String


## The text of the Dialogue Node AST.
## Example: "I need some coffee."
@export_multiline var text: String


## Create a new instance of a Dialogue Node AST.
## Example: ParleyDialogueNodeAst.new("1", Vector2.ZERO, "Alice", "I need some coffee.")
func _init(
	_id: String = "",
	_position: Vector2 = Vector2.ZERO,
	_character: String = "",
	_text: String = ""
) -> void:
	type = ParleyDialogueSequenceAst.Type.DIALOGUE
	id = _id
	position = _position
	character = _character
	text = _text


## Update a Dialogue Node AST.
## Example: node.update("Alice", "I need some coffee.")
func update(_character: String, _text: String) -> void:
	character = _character
	text = _text


static func get_colour() -> Color:
	return Color("#266145")


#region UTILS
func resolve_character() -> ParleyCharacter:
	return ParleyCharacterStore.resolve_character_ref(character)
#endregion
