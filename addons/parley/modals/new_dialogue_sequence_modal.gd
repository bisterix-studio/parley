# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

@tool
extends Window


#region DEFS
@onready var path_edit: LineEdit = %PathEdit
@onready var title_edit: LineEdit = %TitleEdit
@onready var choose_path_modal: FileDialog = %ChoosePathModal


signal dialogue_ast_created(dialogue_ast: ParleyDialogueSequenceAst)
#endregion


func _exit_tree() -> void:
	if path_edit:
		path_edit.text = ""


#region SIGNALS
func _on_file_dialog_file_selected(path: String) -> void:
	if path_edit:
		path_edit.text = path


func _on_choose_path_button_pressed() -> void:
	choose_path_modal.show()
	# TODO: get this from config (note, see the Node inspector as well)
	choose_path_modal.current_dir = "res://dialogue_sequences"
	choose_path_modal.current_file = "new_dialogue.ds"


func _on_cancel_button_pressed() -> void:
	hide()


func _on_create_button_pressed() -> void:
	if not path_edit or not title_edit:
		return
	hide()
	var dialogue_sequence_ast: ParleyDialogueSequenceAst = await ParleyUtils.file.create_new_resource(
		ParleyDialogueSequenceAst.new(title_edit.text),
		path_edit.text,
		get_tree().create_timer(30).timeout
	)
	if dialogue_sequence_ast:
		dialogue_ast_created.emit(dialogue_sequence_ast)
#endregion
