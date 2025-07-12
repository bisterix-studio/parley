# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

@tool
class_name ParleyExportToCsvModal extends Window


@onready var path_editor: LineEdit = %PathEdit
@onready var choose_path_modal: FileDialog = %ChoosePathModal

@export var dialogue_ast: ParleyDialogueSequenceAst

# TODO: get from config
var base_path: String
var export_path: String


func render() -> void:
	base_path = "res://exports".trim_suffix('/')
	var timestamp: String = str(int(Time.get_unix_time_from_system()))
	var dialogue_ast_path: String = dialogue_ast.resource_path if dialogue_ast.resource_path else "dialogue.ds"
	var dialogue_ast_path_parts: PackedStringArray = dialogue_ast_path.split('/')
	var dialogue_sequence_name: String = dialogue_ast_path_parts[dialogue_ast_path_parts.size() - 1].to_snake_case().replace('.ds', '')
	export_path = "%s/export_%s_%s.csv" % [base_path, timestamp, dialogue_sequence_name]
	path_editor.text = export_path
	show()


func _on_export_button_pressed() -> void:
	if not dialogue_ast:
		push_error(ParleyUtils.log.error_msg("No Dialogue AST associated with export."))
		return
	var csv_lines: Array[PackedStringArray] = dialogue_ast.to_csv_lines()
	var dir: DirAccess = DirAccess.open(base_path)
	if dir:
		# TODO: maybe add a message for a gdignore
		# Or probably just mention this in the docs as there are
		# some tricky things that need to be considered.
		var file: FileAccess = FileAccess.open(export_path, FileAccess.WRITE)
		if file:
			for line: PackedStringArray in csv_lines:
				var _result: bool = file.store_csv_line(line)
			file.close()
		else:
			push_error(ParleyUtils.log.error_msg("An error occurred while exporting Dialogue to CSV at path: %s." % [export_path]))
			
	else:
		push_error(ParleyUtils.log.error_msg("An error occurred when trying to access the base path: %s." % [base_path]))
	hide()


func _on_choose_path_modal_file_selected(path: String) -> void:
	path_editor.text = path


func _on_cancel_button_pressed() -> void:
	hide()


func _on_choose_path_button_pressed() -> void:
	choose_path_modal.show()
	choose_path_modal.current_dir = base_path
	choose_path_modal.current_file = export_path
