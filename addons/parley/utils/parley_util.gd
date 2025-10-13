# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

@tool
class_name ParleyUtils


class signals:
	## Connect safely to a signal and handle any errors accordingly
	static func safe_connect(signal_to_connect: Signal, callable: Callable, log_error: bool = false) -> void:
		var connect_result: int = ERR_INVALID_PARAMETER
		if not signal_to_connect.is_connected(callable):
			connect_result = signal_to_connect.connect(callable)
		if connect_result == OK:
			return
		if connect_result == ERR_INVALID_PARAMETER:
			if log_error:
				push_error(log.error_msg("Signal %s already connected" % [signal_to_connect.get_name()]))
		else:
			push_error(log.error_msg("Error connecting signal %s: %d" % [signal_to_connect.get_name(), connect_result]))


	## Disconnect safely from a signal and handle any errors accordingly
	static func safe_disconnect(signal_to_disconnect: Signal, callable: Callable, log_error: bool = false) -> void:
		var connect_result: int = ERR_INVALID_PARAMETER
		if signal_to_disconnect.is_connected(callable):
			return signal_to_disconnect.disconnect(callable)
		if connect_result == ERR_INVALID_PARAMETER:
			if log_error:
				push_error(log.error_msg("Signal %s already disconnected" % [signal_to_disconnect.get_name()]))
		else:
			push_error(log.error_msg("Error disconnecting signal %s: %d" % [signal_to_disconnect.get_name(), connect_result]))


class log:
	static func info_msg(message: String) -> String:
		return "[color=web_gray]PARLEY_DBG: %s[/color]" % [message]


	static func warn_msg(message: String) -> String:
		return "PARLEY_WRN: %s" % [message]


	static func error_msg(message: String) -> String:
		return "PARLEY_ERR: %s" % [message]


class resource:
	static func get_uid(resource: Resource) -> String:
		if not resource or not resource.resource_path:
			push_warning(ParleyUtils.log.warn_msg("Unable to get UID for Resource (resource: %s): resource_path is not defined. Returning empty string." % [resource]))
			return ""
		var id: int = ResourceLoader.get_resource_uid(resource.resource_path)
		if id == -1:
			push_warning(ParleyUtils.log.warn_msg("Unable to get UID for Resource (resource: %s): no such ID exists. Returning empty string." % [resource]))
			return ""
		return ResourceUID.id_to_text(id)


class generate:
	static func id(array: Array, parent_id: String, name: String = "") -> String:
		var local_id: String
		if not name:
			local_id = str(array.size())
		else:
			local_id = name.to_snake_case().to_lower()
		return "%s:%s" % [parent_id.to_snake_case().to_lower(), local_id]


class file:
	static func create_new_resource(resource: Resource, raw_path: String, timeout: Signal) -> Resource:
		var path: String = raw_path.simplify_path() if raw_path.begins_with('res://') else "res://%s" % raw_path.simplify_path()
		var dir: String = path.get_base_dir()
		if not DirAccess.dir_exists_absolute(dir):
			var dir_ok: int = DirAccess.make_dir_recursive_absolute(dir)
			if dir_ok != OK:
				push_error(ParleyUtils.log.error_msg("Error creating directory at path %s for %s: %s" % [dir, resource, dir_ok]))
				return null
		var ok: int = ResourceSaver.save(resource, path)
		if ok != OK:
			push_error(ParleyUtils.log.error_msg("Error creating resource %s at path %s: %s" % [resource, path, ok]))
			return null
		# When a file is created (especially one that has a new directory), the file system is not
		# immediately updated. Therefore, we must wait for this to be updated before loading
		# the saved resource into memory for use within the Parley Graph view.
		if Engine.is_editor_hint():
			EditorInterface.get_resource_filesystem().scan()
			signals.safe_connect(timeout, _emit_filesystem_changed.bind(timeout))
			while EditorInterface.get_resource_filesystem().get_scanning_progress() < 1:
				await EditorInterface.get_resource_filesystem().filesystem_changed
			signals.safe_disconnect(timeout, _emit_filesystem_changed)
		return load(path)
	
	static func _emit_filesystem_changed(timeout: Signal) -> void:
		EditorInterface.get_resource_filesystem().filesystem_changed.emit()
		signals.safe_disconnect(timeout, _emit_filesystem_changed)


class translation:
	## Get the translation context for a node field.
	## If it can't be found, default to empty string.
	static func get_msg_ctx(node: ParleyNodeAst, field: String, suffix: StringName = &"_translation_key") -> String:
		var result_variant: Variant = node.get(field + suffix)
		if is_instance_of(result_variant, TYPE_STRING):
			var result: String = result_variant
			return result
		return ""


	## Translate the input string
	static func translate(input: StringName) -> String:
		var instance: Object = new()
		var resource_path: String = instance.get_script().resource_path
		var base_path: String = resource_path.get_base_dir()
		instance.free()

		var paths: Array[String] = [
			TranslationServer.get_tool_locale(),
			TranslationServer.get_tool_locale().substr(0, 2),
			"en",
		].map(func (locale: String) -> String: return "%s/locale/%s.po" % [base_path, locale])
		for path: String in paths:
			if FileAccess.file_exists(path):
				var translations: Translation = load(path)
				return translations.get_message(input)
		return input


	## Generate a translation key for the target node field.
	## For a correctly generated key, the following must be true: [br]
	##  - The Dialogue Sequence AST must exist in the file system[br]
	##  - The field must exist and be populated on the node[br]
	##  - The field on the node must be of type String[br]
	static func generate_key(input: String, dialogue_sequence_ast: ParleyDialogueSequenceAst = null, node_ast: ParleyNodeAst = null, field: String = "") -> String:
		if not dialogue_sequence_ast or not dialogue_sequence_ast.resource_path or not ResourceLoader.exists(dialogue_sequence_ast.resource_path):
			push_warning(log.warn_msg("Unable to generate translation key: No Dialogue Sequence AST exists (dialogue_sequence_ast: %s, node: %s, field: %s)" % [dialogue_sequence_ast, node_ast, field]))
			return ""

		if not is_instance_of(node_ast.get(field), TYPE_STRING):
			push_warning(log.warn_msg("Unable to generate translation key: field does not exist on Node AST (dialogue_sequence_ast: %s, node: %s, field: %s)" % [dialogue_sequence_ast, node_ast, field]))
			return ""

		var suffix: String = "__" + "_".join([
			resource.get_uid(dialogue_sequence_ast).replace("uid://", ''),
			node_ast.id.replace(node_ast.id_prefix, ''),
			field
		]).to_upper()

		var special_character_regex: RegEx = RegEx.create_from_string("[^\\w\\s]")
		var space_regex: RegEx = RegEx.create_from_string("[\\s]+")
		var result: String = special_character_regex.sub(input.strip_edges(), '', true)
		result = space_regex.sub(result, ' ', true)
		return result.to_snake_case().to_upper().substr(0, 32) + suffix
	

	static func get_csv_key_value(node_ast: ParleyNodeAst, field_to_translate: StringName) -> PackedStringArray:
		var key: String = ParleyUtils.translation.get_msg_ctx(node_ast, field_to_translate)
		var value_variant: Variant = node_ast.get(field_to_translate)
		var value: String = value_variant if is_instance_of(value_variant, TYPE_STRING) else ""
		return PackedStringArray([key if key else value, value])
	

	static func get_locale() -> StringName:
		# TODO: get locale_key from config but for now default to project-then-system locale
		var locale: StringName = ProjectSettings.get_setting("internationalization/locale/fallback")
		if locale:
			return locale

		return TranslationServer.get_tool_locale()
	

	static func get_csv_key_name() -> StringName:
		# TODO: get from config
		return &"keys"


class string:
	static func get_enum_key_name(input: Dictionary, key: int) -> String:
		var key_name: String = input.keys()[key]
		return key_name.capitalize()
