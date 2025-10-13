# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

@tool
class_name ParleyImportModal extends Window


#region DEFS
@onready var path_editor: LineEdit = %PathEdit
@onready var choose_path_modal: FileDialog = %ChoosePathModal
@onready var status_label: RichTextLabel = %Status
@onready var dialogue_sequence_editor: ParleyResourceEditor = %DialogueSequenceEditor


var dialogue_sequence_ast: ParleyDialogueSequenceAst : set = _set_dialogue_sequence_ast


# TODO: get from config
var base_path: String
var import_path: String : set = _set_import_file_path
var file_type: FileType = FileType.Csv
var import_type: ImportType = ImportType.DialogueTextTranslation : set = _set_import_type


enum FileType {
	Csv,
}


enum ImportType {
	DialogueTextTranslation,
}


signal import_requested(import_type: ImportType, file_type: FileType, dialogue_sequence_ast: ParleyDialogueSequenceAst, path: String)
#endregion


#region LIFECYCLE
func _ready() -> void:
	_render_title()
	_render_status()
	_render_dialogue_sequence_editor()
#endregion


#region SETTERS
func _set_import_type(new_import_type: ImportType) -> void:
	import_type = new_import_type
	_render_title()
	_render_status()


func _set_file_type(new_file_type: FileType) -> void:
	file_type = new_file_type
	_render_title()
	_render_status()


func _set_dialogue_sequence_ast(new_dialogue_sequence_ast: ParleyDialogueSequenceAst) -> void:
	dialogue_sequence_ast = new_dialogue_sequence_ast
	_render_dialogue_sequence_editor()


func _set_import_file_path(new_import_path: String) -> void:
	import_path = new_import_path
	_render_path_editor()
#endregion


#region RENDERERS
# TODO: check where this is called
func render(p_import_type: ImportType, p_file_type: FileType, p_dialogue_sequence_ast: ParleyDialogueSequenceAst) -> void:
	file_type = p_file_type
	import_type = p_import_type
	dialogue_sequence_ast = p_dialogue_sequence_ast

	if not path_editor:
		return
	base_path = "res://imports"
	import_path = base_path.path_join(_generate_file_name())
	show()


func _render_title() -> void:
	title = "Import %s to %s" % [_get_import_type_name(), _get_file_type_name()]


func _render_dialogue_sequence_editor() -> void:
	if dialogue_sequence_editor and dialogue_sequence_ast:
		dialogue_sequence_editor.resource = dialogue_sequence_ast


func _render_status() -> void:
	var text: String = """[color=#19e34f]
[ul]%s path name is valid[/ul][/color][color=#19e34f]
[ul]Will import the selected %s to the current %s.[/ul][/color][color=#19e34f]
[ul]If a matching text translation key is found, the node text will be replaced by the configured project locale translation.[/ul][/color]
""" % [_get_file_type_name(), _get_file_type_name(), _get_import_type_name()]
	if status_label:
		status_label.text = text


func _render_path_editor() -> void:
	if path_editor and path_editor.text != import_path:
		path_editor.text = import_path
#endregion


#region SIGNALS
func _on_import_button_pressed() -> void:
	if not dialogue_sequence_ast:
		push_error(ParleyUtils.log.error_msg("No Dialogue Sequence AST associated with import."))
		return
	import_requested.emit(import_type, file_type, dialogue_sequence_ast, import_path)
	hide()


func _on_choose_path_modal_file_selected(path: String) -> void:
	base_path = path.get_base_dir()
	import_path = path


func _on_cancel_button_pressed() -> void:
	hide()


func _on_close_requested() -> void:
	hide()


func _on_choose_path_button_pressed() -> void:
	if choose_path_modal:
		choose_path_modal.show()
		choose_path_modal.current_dir = base_path
		choose_path_modal.current_file = import_path
#endregion


#region CRUD
func _generate_file_name() -> String:
	return "import.csv"


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


func _get_import_type_name() -> String:
	match import_type:
		ImportType.DialogueTextTranslation:
			return "Dialogue Text Translations"
		_:
			push_warning(ParleyUtils.log.warn_msg("Unknown Import Type: %s, defaulting to Dialogue Text Translations" % ParleyUtils.string.get_enum_key_name(ImportType, import_type)))
			return "Dialogue Text Translations"
#endregion
