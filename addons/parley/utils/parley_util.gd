@tool
class_name ParleyUtils

## Connect safely to a signal and handle any errors accordingly
static func safe_connect(signal_to_connect: Signal, callable: Callable, log_error: bool = false) -> void:
	var connect_result: int = ERR_INVALID_PARAMETER
	if not signal_to_connect.is_connected(callable):
		connect_result = signal_to_connect.connect(callable)
	if connect_result == OK:
		return
	if connect_result == ERR_INVALID_PARAMETER:
		if log_error:
			log.error("Signal %s already connected" % [signal_to_connect.get_name()])
	else:
		log.error("Error connecting signal %s: %d" % [signal_to_connect.get_name(), connect_result])

## Disconnect safely from a signal and handle any errors accordingly
static func safe_disconnect(signal_to_disconnect: Signal, callable: Callable, log_error: bool = false) -> void:
	var connect_result: int = ERR_INVALID_PARAMETER
	if signal_to_disconnect.is_connected(callable):
		return signal_to_disconnect.disconnect(callable)
	if connect_result == ERR_INVALID_PARAMETER:
		if log_error:
			log.error("Signal %s already disconnected" % [signal_to_disconnect.get_name()])
	else:
		log.error("Error disconnecting signal %s: %d" % [signal_to_disconnect.get_name(), connect_result])

class log:
	static func info(message: String, dry_run: bool = false) -> void:
		if not dry_run:
			print_rich("[color=web_gray]PARLEY_DBG: %s[/color]" % [message])

	static func warn(message: String, dry_run: bool = false) -> void:
		if not dry_run:
			push_warning("PARLEY_WRN: %s" % [message])

	static func error(message: String, dry_run: bool = false) -> void:
		if not dry_run:
			push_error("PARLEY_ERR: %s" % [message])


class generate:
	static func id(array: Array, parent_id: String, name: String = "") -> String:
		var local_id: String
		if not name:
			local_id = str(array.size())
		else:
			local_id = name.to_snake_case().to_lower()
		return "%s:%s" % [parent_id.to_snake_case().to_lower(), local_id]
