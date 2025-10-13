@tool
extends Node


static func export_node(file_type: ParleyExportModal.FileType, dialogue_sequence_ast: ParleyDialogueSequenceAst, path: String) -> Array:
	var export_type: ParleyExportModal.ExportType = ParleyExportModal.ExportType.Node
	var file_type_name: String = ParleyUtils.string.get_enum_key_name(ParleyExportModal.FileType, file_type)
	var export_type_name: String = ParleyUtils.string.get_enum_key_name(ParleyExportModal.ExportType, export_type)

	# Ensure the directory exists
	if not path.is_absolute_path():
		var message: String = "Unable to export Dialogue Sequence Nodes: Path must be absolute (file_type:%s, export_type:%s, path:%s)" % [file_type_name, export_type_name, path]
		push_error(ParleyUtils.log.error_msg(message))
		return [ERR_INVALID_DATA, message]
	var dir_path: String = path.get_base_dir()
	var dir_result: int = DirAccess.make_dir_recursive_absolute(dir_path)
	if dir_result != OK:
		var message: String = "Unable to export Dialogue Sequence Nodes: Unable to create directory: %s (file_type:%s, export_type:%s, dir_path:%s)" % [error_string(dir_result), file_type_name, export_type_name, dir_path]
		push_error(ParleyUtils.log.error_msg(message))
		return [dir_result, message]

	# Open the file for writing
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if not file:
		var message: String = "Unable to export Dialogue Sequence Nodes: Unable to open file (file_type:%s, export_type:%s, path:%s)" % [file_type_name, export_type_name, path]
		push_error(ParleyUtils.log.error_msg(message))
		return [ERR_INVALID_DATA, message]

	var data: Array[PackedStringArray] = dialogue_sequence_ast.to_csv_lines()
	match file_type:
		ParleyExportModal.FileType.Csv:
			for datum: PackedStringArray in data:
				var result: bool = file.store_csv_line(datum)
				if not result:
					var message: String = "Unable to export Dialogue Sequence Nodes: Unable to store csv line to file (file_type:%s, export_type:%s, path:%s, line:%s)" % [file_type_name, export_type_name, path, datum]
					push_error(ParleyUtils.log.error_msg(message))
					file.close()
					return [ERR_INVALID_DATA, message]
		_:
			var message: String = "Unable to export Dialogue Sequence Nodes: Unknown file type (file_type:%s, export_type:%s)" % [file_type_name, export_type_name]
			push_error(ParleyUtils.log.error_msg(message))
			file.close()
			return [ERR_INVALID_DATA, message]
	return [OK, ""]


static func export_dialogue_text_translation(file_type: ParleyExportModal.FileType, dialogue_sequence_ast: ParleyDialogueSequenceAst, path: String) -> Array:
	var lines: Array[PackedStringArray] = []
	var used_keys: Dictionary[String, bool] = {}
	for node_ast: ParleyNodeAst in dialogue_sequence_ast.nodes:
		if [ParleyDialogueSequenceAst.Type.DIALOGUE, ParleyDialogueSequenceAst.Type.DIALOGUE_OPTION].has(node_ast.type):
			var line: PackedStringArray = ParleyUtils.translation.get_csv_key_value(node_ast, &'text')
			var text_key: StringName = line[0] # The first element is always the key
			if not used_keys.has(text_key):
					lines.append(line)
					var _result: int = used_keys.set(text_key, true)
	
	var key: StringName = ParleyUtils.translation.get_csv_key_name()
	var locale: StringName = ParleyUtils.translation.get_locale()
	return _export(file_type, ParleyExportModal.ExportType.DialogueTextTranslation, path, lines, key, locale)


static func export_character_name_translation(file_type: ParleyExportModal.FileType, dialogue_sequence_ast: ParleyDialogueSequenceAst, path: String) -> Array:
	var lines: Array[PackedStringArray] = []
	var used_keys: Dictionary[String, bool] = {}
	for node_ast: ParleyNodeAst in dialogue_sequence_ast.nodes:
		if [ParleyDialogueSequenceAst.Type.DIALOGUE, ParleyDialogueSequenceAst.Type.DIALOGUE_OPTION].has(node_ast.type):
			var character_ref_variant: Variant = node_ast.get('character')
			if is_instance_of(character_ref_variant, TYPE_STRING):
				var character_ref: String = character_ref_variant
				var character: ParleyCharacter = ParleyCharacterStore.resolve_character_ref(character_ref)
				var character_key: StringName = character.name
				if not used_keys.has(character_key):
					lines.append(PackedStringArray([character_key, character.name]))
					var _result: int = used_keys.set(character_key, true)
	
	var key: StringName = ParleyUtils.translation.get_csv_key_name()
	var locale: StringName = ParleyUtils.translation.get_locale()
	return _export(file_type, ParleyExportModal.ExportType.CharacterNameTranslation, path, lines, key, locale)


static func _export(file_type: ParleyExportModal.FileType, export_type: ParleyExportModal.ExportType, path: String, lines: Array[PackedStringArray], key: StringName, locale: StringName) -> Array:
	var file_type_name: String = ParleyUtils.string.get_enum_key_name(ParleyExportModal.FileType, file_type)
	var export_type_name: String = ParleyUtils.string.get_enum_key_name(ParleyExportModal.ExportType, export_type)

	# Ensure the directory exists
	if not path.is_absolute_path():
		var message: String = "Unable to export: Path must be absolute (file_type:%s, export_type:%s, path:%s)" % [file_type_name, export_type_name, path]
		push_error(ParleyUtils.log.error_msg(message))
		return [ERR_INVALID_DATA, message]
	var dir_path: String = path.get_base_dir()
	var dir_result: int = DirAccess.make_dir_recursive_absolute(dir_path)
	if dir_result != OK:
		var message: String = "Unable to export: Unable to create directory: %s (file_type:%s, export_type:%s, dir_path:%s)" % [error_string(dir_result), file_type_name, export_type_name, dir_path]
		push_error(ParleyUtils.log.error_msg(message))
		return [dir_result, message]

	# Open the file for reading and move on if it does not exist
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	var file_result: int = FileAccess.get_open_error()
	if not file and not [OK, ERR_FILE_NOT_FOUND].has(file_result):
		var message: String = "Unable to export: Unable to open existing file for reading: %s (file_type:%s, export_type:%s, path:%s)" % [error_string(file_result), file_type_name, export_type_name, path]
		push_error(ParleyUtils.log.error_msg(message))
		return [ERR_INVALID_DATA, message]

	# Read existing lines
	var lines_to_store: Array[PackedStringArray] = []
	var existing_lines_map: Dictionary[String, int] = {} # Store in a dict for quicker processing
	# TODO: set keys from config
	# TODO: get locale_key from config but for now default to system locale
	var headers: PackedStringArray = PackedStringArray([key, locale])
	if file:
		var index: int = 0
		while !file.eof_reached():
			var line: PackedStringArray = file.get_csv_line()
			if line.size() >= 2 and line[0] != "":
				lines_to_store.append(line)
				existing_lines_map[line[0]] = index
				index += 1
		file.close()

	# Open a file for writing and truncate existing
	file = FileAccess.open(path, FileAccess.WRITE)
	file_result = FileAccess.get_open_error()
	if not file or file_result != OK:
		if file:
			file.close()
		var message: String = "Unable to export: Unable to open file for writing: %s (file_type:%s, export_type:%s, path:%s)" % [error_string(file_result), file_type_name, export_type_name, path]
		push_error(ParleyUtils.log.error_msg(message))
		return [ERR_INVALID_DATA if file_result == OK else file_result, message]

	# Add header if nothing read, otherwise set headers
	if lines_to_store.size() == 0:
		lines_to_store.append(headers)
	else:
		headers = lines_to_store[0]

	match file_type:
		ParleyExportModal.FileType.Csv:
			for key_values: PackedStringArray in lines:
				var entry_key: String = key_values.get(0)
				if not entry_key:
					continue
				if key_values.size() < 2:
					continue
				var value: String = key_values[1]

				# Handle existing lines
				var existing_line_index: int = existing_lines_map.get(entry_key, -1)
				if existing_line_index >= 0 and existing_line_index < lines_to_store.size():
					var column_index: int = headers.find(locale)
					var existing_line: PackedStringArray = lines_to_store[existing_line_index]
					var override_value: bool = false
					if column_index >= 0:
						var existing_value: String = existing_line[column_index]
						override_value = existing_value != value and value != entry_key

					var existing_line_to_store: PackedStringArray = PackedStringArray([key_values[0]])
					var index: int = 1
					for header: String in headers.slice(1):
						var column_value: String = existing_line[index]
						# Columns starting with an underscore are interpreted as a comment: https://docs.godotengine.org/en/4.4/tutorials/assets_pipeline/importing_translations.html#translation-format
						if header.begins_with('_'):
							# TODO: support _notes
							var _result: int = existing_line_to_store.append(column_value)
						else:
							var _result: int = existing_line_to_store.append(value if override_value else column_value)
						index += 1
					lines_to_store[existing_line_index] = existing_line_to_store
					continue

				# Handle new lines
				var new_line_to_store: PackedStringArray = PackedStringArray([key_values[0]])
				for header: String in headers.slice(1):
					# Columns starting with an underscore are interpreted as a comment: https://docs.godotengine.org/en/4.4/tutorials/assets_pipeline/importing_translations.html#translation-format
					if header.begins_with('_'):
						# TODO: support _notes
						var _result: int = new_line_to_store.append("")
					else:
						var _result: int = new_line_to_store.append(value)
				lines_to_store.append(new_line_to_store)
		_:
			var message: String = "Unable to export: Unknown file type (file_type:%s, export_type:%s)" % [file_type_name, export_type_name]
			push_error(ParleyUtils.log.error_msg(message))
			file.close()
			return [ERR_INVALID_DATA, message]

	for line: PackedStringArray in lines_to_store:
		var store_result: bool = file.store_csv_line(line)
		if not store_result:
			var message: String = "Unable to export: Unable to store csv line to file (file_type:%s, export_type:%s, path:%s, line:%s)" % [file_type_name, export_type_name, path, line]
			push_error(ParleyUtils.log.error_msg(message))
			file.close()
			return [ERR_INVALID_DATA, message]
	file.close()
	return [OK, ""]
