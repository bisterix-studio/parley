# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

@tool
extends Window

@onready var path_edit: LineEdit = %PathEdit
@onready var choose_path_modal: FileDialog = %ChoosePathModal

signal dialogue_ast_created(dialogue_ast: ParleyDialogueSequenceAst)


# TODO: is this needed?
func _exit_tree() -> void:
	path_edit.text = ""


func _on_file_dialog_file_selected(path: String) -> void:
	path_edit.text = path


func _on_choose_path_button_pressed() -> void:
	choose_path_modal.show()
	# TODO: get this from config (note, see the Node inspector as well)
	choose_path_modal.current_dir = "res://dialogue_sequences"
	choose_path_modal.current_file = "new_dialogue.ds"


func _on_cancel_button_pressed() -> void:
	hide()


func _on_create_button_pressed() -> void:
	hide()
	var dialogue_sequence_ast: ParleyDialogueSequenceAst = await ParleyUtils.file.create_new_resource(
		ParleyDialogueSequenceAst.new(),
		path_edit.text,
		get_tree().create_timer(30).timeout
	)
	if dialogue_sequence_ast:
		dialogue_ast_created.emit(dialogue_sequence_ast)
