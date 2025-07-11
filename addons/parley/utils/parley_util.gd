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
