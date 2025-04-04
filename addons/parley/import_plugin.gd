@tool
extends EditorImportPlugin

const compiler_version: String = "0.2.0"

enum Presets {DEFAULT}

func _get_importer_name():
	# NOTE: A change to this forces a re-import of all dialogue
	return "parley_dialogue_ast_compiler_%s" % compiler_version

func _get_visible_name():
	# "Import as Parley Dialogue AST"
	return "Parley Dialogue AST"


func _get_recognized_extensions():
	return ["ds"]


func _get_save_extension():
	return "tres"


func _get_resource_type():
	return "Resource"


func _get_preset_count():
	return Presets.size()


func _get_preset_name(preset_index):
	match preset_index:
		Presets.DEFAULT:
			return "Default"
		_:
			return "Unknown"


func _get_priority():
	return 2
	

func _get_import_order() -> int:
	return -1000


func _get_import_options(path, preset_index):
	match preset_index:
		Presets.DEFAULT:
			return []
		_:
			return []


func _get_option_visibility(path, option_name, options):
	return true


func _import(source_file, save_path, options, r_platform_variants, r_gen_files) -> int:
	# Serialisation
	var file = FileAccess.open(source_file, FileAccess.READ)
	if file == null:
		return FileAccess.get_open_error()
	var raw_text = file.get_as_text()
	var raw_ast = JSON.parse_string(raw_text)

	# Validation
	var title = raw_ast.get('title')
	var nodes = raw_ast.get('nodes')
	var edges = raw_ast.get('edges')
	var stores = raw_ast.get('stores')
	if not is_instance_of(title, TYPE_STRING):
		push_error("PARLEY_ERR: Unable to load Parley Dialogue JSON as valid AST because required field 'title' is not a valid string")
		return ERR_PARSE_ERROR
	if not is_instance_of(nodes, TYPE_ARRAY):
		push_error("PARLEY_ERR: Unable to load Parley Dialogue JSON as valid AST because required field 'nodes' is not a valid Array")
		return ERR_PARSE_ERROR
	if not is_instance_of(edges, TYPE_ARRAY):
		push_error("PARLEY_ERR: Unable to load Parley Dialogue JSON as valid AST because required field 'edges' is not a valid Array")
		return ERR_PARSE_ERROR
	if not is_instance_of(stores, TYPE_DICTIONARY):
		push_error("PARLEY_ERR: Unable to load Parley Dialogue JSON as valid AST because required field 'stores' is not a valid Dictionary")
		return ERR_PARSE_ERROR

	# Compilation
	var dialogue_ast = DialogueAst.new(title, nodes, edges, stores)
	return ResourceSaver.save(dialogue_ast, "%s.%s" % [save_path, _get_save_extension()])
