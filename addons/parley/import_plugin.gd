# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

@tool
extends EditorImportPlugin

const compiler_version: String = "0.2.0"

enum Presets {DEFAULT}

func _get_importer_name() -> String:
	# NOTE: A change to this forces a re-import of all dialogue
	return "parley_dialogue_ast_compiler_%s" % compiler_version

func _get_visible_name() -> String:
	# "Import as Parley Dialogue AST"
	return "Parley Dialogue AST"


func _get_recognized_extensions() -> PackedStringArray:
	return ["ds"]


func _get_save_extension() -> String:
	return "tres"


func _get_resource_type() -> String:
	return "Resource"


func _get_preset_count() -> int:
	return Presets.size()


func _get_preset_name(preset_index: int) -> String:
	match preset_index:
		Presets.DEFAULT:
			return "Default"
		_:
			return "Unknown"


func _get_priority() -> float:
	return 2
	

func _get_import_order() -> int:
	return -1000


func _get_import_options(_path: String, preset_index: int) -> Array[Dictionary]:
	match preset_index:
		Presets.DEFAULT:
			return []
		_:
			return []


func _get_option_visibility(_path: String, _option_name: StringName, _options: Dictionary) -> bool:
	return true


func _import(source_file: String, save_path: String, _options: Dictionary, _platform_variants: Array[String], _gen_files: Array[String]) -> int:
	# Serialisation
	var file: FileAccess = FileAccess.open(source_file, FileAccess.READ)
	if file == null:
		return FileAccess.get_open_error()
	var raw_text: String = file.get_as_text()
	var raw_ast: Variant = JSON.parse_string(raw_text)
	if not is_instance_of(raw_ast, TYPE_DICTIONARY):
		ParleyUtils.log.error("Unable to load Parley Dialogue JSON as valid AST because it is not a valid dictionary")
		return ERR_PARSE_ERROR
	var ast_dict: Dictionary = raw_ast

	# Validation
	var _title: Variant = ast_dict.get('title')
	var _nodes: Variant = ast_dict.get('nodes')
	var _edges: Variant = ast_dict.get('edges')
	if not is_instance_of(_title, TYPE_STRING):
		ParleyUtils.log.error("Unable to load Parley Dialogue JSON as valid AST because required field 'title' is not a valid string")
		return ERR_PARSE_ERROR
	if not is_instance_of(_nodes, TYPE_ARRAY):
		ParleyUtils.log.error("Unable to load Parley Dialogue JSON as valid AST because required field 'nodes' is not a valid Array")
		return ERR_PARSE_ERROR
	if not is_instance_of(_edges, TYPE_ARRAY):
		ParleyUtils.log.error("Unable to load Parley Dialogue JSON as valid AST because required field 'edges' is not a valid Array")
		return ERR_PARSE_ERROR
	var title: String = _title
	var nodes: Array = _nodes
	var edges: Array = _edges

	# Compilation
	var dialogue_ast: ParleyDialogueSequenceAst = ParleyDialogueSequenceAst.new(title, nodes, edges)
	return ResourceSaver.save(dialogue_ast, "%s.%s" % [save_path, _get_save_extension()])
