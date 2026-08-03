# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

@tool
class_name ParleyExportModal extends Window


#region DEFS
@onready var path_editor: LineEdit = %PathEdit
@onready var choose_path_modal: FileDialog = %ChoosePathModal
@onready var status_label: RichTextLabel = %Status


# TODO: rename
@export var dialogue_ast: ParleyDialogueSequenceAst


# TODO: get from config
var base_path: String
var export_path: String
var file_type: FileType = FileType.Csv
var export_type: ExportType = ExportType.DialogueTextTranslation : set = _set_export_type


enum FileType {
	Csv,
}


enum ExportType {
	Node,
	DialogueTextTranslation,
	CharacterNameTranslation,
}


signal export_requested(export_type: ExportType, file_type: FileType, dialogue_sequence_ast: ParleyDialogueSequenceAst, path: String)
#endregion


#region LIFECYCLE
func _ready() -> void:
	_render_title()
	_render_status()
#endregion


#region SETTERS
func _set_export_type(new_export_type: ExportType) -> void:
	export_type = new_export_type
	_render_title()
	_render_status()


func _set_file_type(new_file_type: FileType) -> void:
	file_type = new_file_type
	_render_title()
	_render_status()
#endregion


#region RENDERERS
# TODO: check where this is called
func render(p_export_type: ExportType, p_file_type: FileType, p_dialogue_sequence_ast: ParleyDialogueSequenceAst) -> void:
	file_type = p_file_type
	export_type = p_export_type
	dialogue_ast = p_dialogue_sequence_ast

	if not path_editor:
		return
	base_path = "res://exports"

	export_path = base_path.path_join(_generate_file_name())
	path_editor.text = export_path
	show()


func _render_title() -> void:
	title = "Export %s to %s" % [_get_export_type_name(), _get_file_type_name()]


func _render_status() -> void:
	var text: String = """[color=#19e34f]
[ul]%s path name is valid[/ul][/color][color=#19e34f]
[ul]Will export the %s to %s[/ul][/color]
""" % [_get_file_type_name(), _get_export_type_name(), _get_file_type_name()]
	if status_label:
		status_label.text = text
#endregion


#region SIGNALS
func _on_export_button_pressed() -> void:
	if not dialogue_ast:
		push_error(ParleyUtils.log.error_msg("No Dialogue AST associated with export."))
		return
	export_requested.emit(export_type, file_type, dialogue_ast, export_path)
	hide()


func _on_choose_path_modal_file_selected(path: String) -> void:
	if path_editor:
		path_editor.text = path
		base_path = path.get_base_dir()
		export_path = path


func _on_cancel_button_pressed() -> void:
	hide()


func _on_close_requested() -> void:
	hide()


func _on_choose_path_button_pressed() -> void:
	if choose_path_modal:
		choose_path_modal.show()
		choose_path_modal.current_dir = base_path
		choose_path_modal.current_file = export_path
#endregion


#region CRUD
func _generate_file_name() -> String:
	var timestamp: String = str(int(Time.get_unix_time_from_system()))
	var dialogue_sequence_ast_path: String = dialogue_ast.resource_path if dialogue_ast.resource_path else "dialogue.ds"
	var dialogue_sequence_ast_path_parts: PackedStringArray = dialogue_sequence_ast_path.split('/')
	var dialogue_sequence_name: String = dialogue_sequence_ast_path_parts[dialogue_sequence_ast_path_parts.size() - 1].to_snake_case().replace('.ds', '')
	var file_context: String = ""
	match export_type:
		ExportType.DialogueTextTranslation:
			file_context = "dialogue_text_translations"
		ExportType.CharacterNameTranslation:
			file_context = "character_name_translations"
		ExportType.Node:
			file_context = dialogue_sequence_name
	return "export_%s_%s%s" % [file_context, timestamp, _get_file_type_extension()]


func _get_file_type_name() -> String:
	match file_type:
		FileType.Csv:
			return "CSV"
		_:
			push_warning(ParleyUtils.log.warn_msg("Unknown File Type: %s, defaulting to CSV" % ParleyUtils.string.get_enum_key_name(FileType, file_type)))
			return "CSV"


func _get_file_type_extension() -> String:
	match file_type:
		FileType.Csv:
			return ".csv"
		_:
			push_warning(ParleyUtils.log.warn_msg("Unknown File Type: %s, defaulting to CSV" % ParleyUtils.string.get_enum_key_name(FileType, file_type)))
			return ".csv"


func _get_export_type_name() -> String:
	match export_type:
		ExportType.Node:
			return "Dialogue Sequence"
		ExportType.DialogueTextTranslation:
			return "Dialogue Text Translations"
		ExportType.CharacterNameTranslation:
			return "Character Name Translations"
		_:
			push_warning(ParleyUtils.log.warn_msg("Unknown Export Type: %s, defaulting to Dialogue Text Translations" % ParleyUtils.string.get_enum_key_name(ExportType, export_type)))
			return "Dialogue Text Translations"
#endregion
