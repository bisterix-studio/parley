@tool
extends Node


static func import_dialogue_text_translation(file_type: ParleyImportModal.FileType, dialogue_sequence_ast: ParleyDialogueSequenceAst, path: String) -> Array:
	var file_type_name: String = ParleyUtils.string.get_enum_key_name(ParleyImportModal.FileType, file_type)
	var import_type: ParleyImportModal.ImportType = ParleyImportModal.ImportType.DialogueTextTranslation
	var import_type_name: String = ParleyUtils.string.get_enum_key_name(ParleyImportModal.ImportType, import_type)

		# Open the file for reading and return on if it does not exist
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	var file_result: int = FileAccess.get_open_error()
	if not file or file_result != OK:
		var message: String = "Unable to import: Unable to open import file for reading: %s (file_type:%s, import_type:%s, path:%s)" % [error_string(file_result), file_type_name, import_type_name, path]
		push_error(ParleyUtils.log.error_msg(message))
		return [ERR_INVALID_DATA if file_result == OK else file_result, message]

	var index: int = 0
	var key_name: StringName = ParleyUtils.translation.get_csv_key_name()
	var locale: StringName = ParleyUtils.translation.get_locale()
	var headers: PackedStringArray = PackedStringArray([key_name, locale])
	const key_index: int = 0
	var project_locale_column_index: int = headers.find(locale)
	var lines_map: Dictionary[String, String] = {}
	while !file.eof_reached():
		var line: PackedStringArray = file.get_csv_line()
		if line.size() >= 2 and line[0] != "":
			if index == 0:
				headers = line
				project_locale_column_index = headers.find(locale)
				# We assume that key index is always 0
				if project_locale_column_index > key_index:
					pass
				else:
					var message: String = "Unable to import: cannot find valid translation index: (headers:%s, line:%s, locale:%s)" % [headers, line, locale]
					push_error(ParleyUtils.log.error_msg(message))
					file.close()
					return [ERR_INVALID_DATA, message]
			elif project_locale_column_index >= 0 and project_locale_column_index < line.size():
				var translation_field: String = line[project_locale_column_index]
				lines_map[line[key_index]] = translation_field
			else:
				var message: String = "Unable to import: cannot find valid translation field matching the project locale: (headers:%s, line:%s, locale:%s)" % [headers, line, locale]
				push_error(ParleyUtils.log.error_msg(message))
				file.close()
				return [ERR_INVALID_DATA, message]
			index += 1
	file.close()

	var updated: bool = false
	for node_ast: ParleyNodeAst in dialogue_sequence_ast.nodes:
		if not [ParleyDialogueSequenceAst.Type.DIALOGUE, ParleyDialogueSequenceAst.Type.DIALOGUE_OPTION].has(node_ast.type):
			continue

		var field: StringName = &"text"
		var text_translation_key: String = ParleyUtils.translation.get_msg_ctx(node_ast, field)
		var text: String = node_ast.get("text") if node_ast.get("text") else ""
		var key: String = text_translation_key if text_translation_key else text
		var updated_text: String = lines_map.get(key, "")
		if updated_text and is_instance_of(updated_text, TYPE_STRING) and text != updated_text:
			if not text_translation_key:
				ParleyUtils.translation.set_msg_ctx(node_ast, field, key) 
			node_ast.set(field, updated_text)
			updated = true
	
	if updated:
		dialogue_sequence_ast.emit_changed()
		dialogue_sequence_ast.dialogue_updated.emit(dialogue_sequence_ast)

	return [OK, ""]
