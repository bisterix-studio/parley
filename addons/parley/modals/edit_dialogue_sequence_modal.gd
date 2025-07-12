# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

@tool
class_name ParleyEditDialogueSequenceModal extends Window

#region DEFS
var dialogue_sequence_ast: ParleyDialogueSequenceAst = ParleyDialogueSequenceAst.new() : set = _set_dialogue_sequence_ast


@onready var path_edit: LineEdit = %PathEdit
@onready var title_edit: LineEdit = %TitleEdit


signal dialogue_ast_edited(dialogue_ast: ParleyDialogueSequenceAst)
#endregion


#region LIFECYCLE
func _ready() -> void:
	_render_path()
	_render_title()


func _exit_tree() -> void:
	if path_edit:
		path_edit.text = ""
#endregion


#region SETTERS
func _set_dialogue_sequence_ast(new_dialogue_sequence_ast: ParleyDialogueSequenceAst) -> void:
	dialogue_sequence_ast = new_dialogue_sequence_ast
	_render_path()
	_render_title()
#endregion


#region RENDERERS
func _render_path() -> void:
	if path_edit and dialogue_sequence_ast and dialogue_sequence_ast.resource_path:
		path_edit.text = dialogue_sequence_ast.resource_path


func _render_title() -> void:
	if title_edit and dialogue_sequence_ast:
		title_edit.text = dialogue_sequence_ast.title
#endregion


#region SIGNALS
func _on_title_edit_text_changed(new_title: String) -> void:
	if dialogue_sequence_ast and dialogue_sequence_ast.title != new_title:
		dialogue_sequence_ast.title = new_title


func _on_cancel_button_pressed() -> void:
	hide()


func _on_confirm_button_pressed() -> void:
	hide()
	if dialogue_sequence_ast:
		dialogue_ast_edited.emit(dialogue_sequence_ast)
#endregion
