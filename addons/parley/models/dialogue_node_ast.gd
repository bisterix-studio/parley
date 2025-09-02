# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

@tool
class_name ParleyDialogueNodeAst extends ParleyNodeAst


## The character of the Dialogue Node AST.
## Example: "Alice"
@export var character: String


## The text of the Dialogue Node AST.
## Example: "I need some coffee."
@export_multiline var text: String


## The translation id for the text field of the Dialogue Node AST.
## Example: "world_dialect__I_need_some_coffee"
@export var text_translation_key: String


## Create a new instance of a Dialogue Node AST.
## Example: ParleyDialogueNodeAst.new("1", Vector2.ZERO, "Alice", "I need some coffee.")
func _init(
	p_id: String = "",
	p_position: Vector2 = Vector2.ZERO,
	p_character: String = "",
	p_text: String = "",
	p_text_translation_key: String = ""
) -> void:
	type = ParleyDialogueSequenceAst.Type.DIALOGUE
	id = p_id
	position = p_position
	character = p_character
	text = p_text
	text_translation_key = p_text_translation_key


## Update a Dialogue Node AST.
## Example: node.update("Alice", "I need some coffee.")
func update(p_character: String, p_text: String, p_text_translation_key: String) -> void:
	character = p_character
	text = p_text
	text_translation_key = p_text_translation_key


static func get_colour() -> Color:
	return Color("#266145")


#region UTILS
func to_resolved(resolved_text: String) -> ParleyDialogueNodeAst:
	return ParleyDialogueNodeAst.new(
		id,
		position,
		character,
		resolved_text,
		text_translation_key
	)


func resolve_character() -> ParleyCharacter:
	return ParleyCharacterStore.resolve_character_ref(character)


## Get translation strings for the Dialogue Node
func get_translation_strings() -> Array[PackedStringArray]:
	var translation_strings: Array[PackedStringArray] = []
	if text:
		translation_strings.append(PackedStringArray([text, ParleyUtils.translation.get_msg_ctx(self, 'text_translation_key')]))
	return translation_strings
#endregion
