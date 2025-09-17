@tool
extends Node


static func export_node(file_type: ParleyExportModal.FileType, dialogue_sequence_ast: ParleyDialogueSequenceAst, path: String) -> void:
	var export_type: ParleyExportModal.ExportType = ParleyExportModal.ExportType.Node
	var file_type_name: String = ParleyUtils.string.get_enum_key_name(ParleyExportModal.FileType, file_type)
	var export_type_name: String = ParleyUtils.string.get_enum_key_name(ParleyExportModal.ExportType, export_type)

	# Ensure the directory exists
	if not path.is_absolute_path():
		push_error(ParleyUtils.log.error_msg("Unable to export Dialogue Sequence Nodes: Path must be absolute (file_type:%s, export_type:%s, path:%s)" % [file_type_name, export_type_name, path]))
		return
	var dir_path: String = path.get_base_dir()
	var dir_result: int = DirAccess.make_dir_recursive_absolute(dir_path)
	if dir_result != OK:
		push_error(ParleyUtils.log.error_msg("Unable to export Dialogue Sequence Nodes: Unable to create directory: %s (file_type:%s, export_type:%s, dir_path:%s)" % [error_string(dir_result), file_type_name, export_type_name, dir_path]))
		return

	# Open the file for writing
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if not file:
		push_error(ParleyUtils.log.error_msg("Unable to export Dialogue Sequence Nodes: Unable to open file (file_type:%s, export_type:%s, path:%s)" % [file_type_name, export_type_name, path]))
		return

	var data: Array[PackedStringArray] = dialogue_sequence_ast.to_csv_lines()
	match file_type:
		ParleyExportModal.FileType.Csv:
			for datum: PackedStringArray in data:
				var result: bool = file.store_csv_line(datum)
				if not result:
					push_error(ParleyUtils.log.error_msg("Unable to export Dialogue Sequence Nodes: Unable to store csv line to file (file_type:%s, export_type:%s, path:%s, line:%s)" % [file_type_name, export_type_name, path, datum]))
					file.close()
					return
		_:
			push_error(ParleyUtils.log.error_msg("Unable to export Dialogue Sequence Nodes: Unknown file type (file_type:%s, export_type:%s)" % [file_type_name, export_type_name]))
			file.close()
			return


static func export_dialogue_text_translation(file_type: ParleyExportModal.FileType, dialogue_sequence_ast: ParleyDialogueSequenceAst, path: String) -> void:
	var lines: Array[PackedStringArray] = []
	for node_ast: ParleyNodeAst in dialogue_sequence_ast.nodes:
		if [ParleyDialogueSequenceAst.Type.DIALOGUE, ParleyDialogueSequenceAst.Type.DIALOGUE_OPTION].has(node_ast.type):
			lines.append(ParleyUtils.translation.get_csv_key_value(node_ast, &'text'))
	# TODO: set keys from config
	# TODO: get locale_key from config but for now default to system locale
	return _export(file_type, ParleyExportModal.ExportType.DialogueTextTranslation, path, lines, &"keys", TranslationServer.get_tool_locale())


static func export_character_name_translation(file_type: ParleyExportModal.FileType, dialogue_sequence_ast: ParleyDialogueSequenceAst, path: String) -> void:
	var lines: Array[PackedStringArray] = []
	for node_ast: ParleyNodeAst in dialogue_sequence_ast.nodes:
		if [ParleyDialogueSequenceAst.Type.DIALOGUE, ParleyDialogueSequenceAst.Type.DIALOGUE_OPTION].has(node_ast.type):
			var character_ref_variant: Variant = node_ast.get('character')
			if is_instance_of(character_ref_variant, TYPE_STRING):
				var character_ref: String = character_ref_variant
				var character: ParleyCharacter = ParleyCharacterStore.resolve_character_ref(character_ref)
				lines.append(PackedStringArray([character.name, character.name]))
	# TODO: set keys from config
	# TODO: get locale_key from config but for now default to system locale
	return _export(file_type, ParleyExportModal.ExportType.CharacterNameTranslation, path, lines, &"keys", TranslationServer.get_tool_locale())


static func _export(file_type: ParleyExportModal.FileType, export_type: ParleyExportModal.ExportType, path: String, lines: Array[PackedStringArray], key: StringName, locale: StringName) -> void:
	var file_type_name: String = ParleyUtils.string.get_enum_key_name(ParleyExportModal.FileType, file_type)
	var export_type_name: String = ParleyUtils.string.get_enum_key_name(ParleyExportModal.ExportType, export_type)

	# Ensure the directory exists
	if not path.is_absolute_path():
		push_error(ParleyUtils.log.error_msg("Unable to export: Path must be absolute (file_type:%s, export_type:%s, path:%s)" % [file_type_name, export_type_name, path]))
		return
	var dir_path: String = path.get_base_dir()
	var dir_result: int = DirAccess.make_dir_recursive_absolute(dir_path)
	if dir_result != OK:
		push_error(ParleyUtils.log.error_msg("Unable to export: Unable to create directory: %s (file_type:%s, export_type:%s, dir_path:%s)" % [error_string(dir_result), file_type_name, export_type_name, dir_path]))
		return

	# Open the file for appending and create if it does not exist
	var file: FileAccess = FileAccess.open(path, FileAccess.READ_WRITE)
	var file_result: int = FileAccess.get_open_error()
	if not file and file_result == ERR_FILE_NOT_FOUND:
		file = FileAccess.open(path, FileAccess.WRITE_READ)
		file_result = FileAccess.get_open_error()
	if not file or file_result != OK:
		push_error(ParleyUtils.log.error_msg("Unable to export: Unable to open file for writing: %s (file_type:%s, export_type:%s, path:%s)" % [error_string(file_result), file_type_name, export_type_name, path]))
		if file:
			file.close()
		return

	# Read existing lines
	var lines_to_store: Array[PackedStringArray] = []
	var existing_lines: Array[PackedStringArray] = []
	var existing_lines_map: Dictionary[String, int] = {} # Store in a dict for quicker processing
	var index: int = 0
	# TODO: set keys from config
	# TODO: get locale_key from config but for now default to system locale
	var headers: PackedStringArray = PackedStringArray([key, locale])
	while !file.eof_reached():
		var line: PackedStringArray = file.get_csv_line()
		existing_lines.append(line)
		existing_lines_map[line[0]] = index
		index += 1

	# Remove the empty last line from existing lines
	# Or add it to the file if it doesn't exist to ensure the CSV is correctly populated
	if existing_lines.size() > 0:
		var last: PackedStringArray = existing_lines[existing_lines.size() - 1]
		if last.size() == 0 or (last.size() == 1 and last[0] == ""):
			existing_lines.pop_back()
		else:
			var _result: int = file.store_line("")

	# Add header if nothing read, otherwise set headers
	if existing_lines.size() == 0:
		lines_to_store.append(headers)
	else:
		headers = existing_lines[0]

	# TODO: remove _
	var _locale_key: String = headers[0]
	var _key_name: StringName = headers[0]

	match file_type:
		ParleyExportModal.FileType.Csv:
			for key_values: PackedStringArray in lines:
				var entry_key: String = key_values.get(0)
				if not entry_key:
					continue
				if key_values.size() < 2:
					continue
				var value: String = key_values[1]

				# Add extra value for each header column so the resultant CSV rows are all aligned with the header
				for header: String in headers.slice(2):
					# Columns starting with an underscore are interpreted as a comment: https://docs.godotengine.org/en/4.4/tutorials/assets_pipeline/importing_translations.html#translation-format
					var _result: int = key_values.append("" if header.begins_with('_') else value)
				lines_to_store.append(key_values)
		_:
			push_error(ParleyUtils.log.error_msg("Unable to export: Unknown file type (file_type:%s, export_type:%s)" % [file_type_name, export_type_name]))
			file.close()
			return

	for line: PackedStringArray in lines_to_store:
		var store_result: bool = file.store_csv_line(line)
		if not store_result:
			push_error(ParleyUtils.log.error_msg("Unable to export: Unable to store csv line to file (file_type:%s, export_type:%s, path:%s, line:%s)" % [file_type_name, export_type_name, path, line]))
			file.close()
			return
	file.close()
