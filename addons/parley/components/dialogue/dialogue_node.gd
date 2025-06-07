# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

@tool
class_name ParleyDialogueNode extends ParleyGraphNode


#region DEFS
@export var character: String = "": set = _on_set_character
@export var dialogue: String = "": set = _on_set_dialogue


@onready var character_editor: Label = %Character
@onready var dialogue_editor: Label = %Dialogue
#endregion


#region LIFECYCLE
func _ready() -> void:
	setup(ParleyDialogueSequenceAst.Type.DIALOGUE)
	clear_all_slots()
	set_slot(0, true, 0, Color.CHARTREUSE, true, 0, Color.CHARTREUSE)
	set_slot_style(0)
	_render_character()
	_render_dialogue()
#endregion


#region SETTERS
func _on_set_character(new_character: String) -> void:
	character = new_character
	_render_character()


func _on_set_dialogue(new_dialogue: String) -> void:
	dialogue = new_dialogue
	_render_dialogue()
#endregion


#region RENDERERS
func _render_character() -> void:
	if character_editor:
		character_editor.text = character


func _render_dialogue() -> void:
	if dialogue_editor:
		dialogue_editor.text = dialogue
#endregion
