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

class log:
	static func info(message: String) -> void:
		print("PARLEY_DBG: %s" % [message])

	static func warn(message: String) -> void:
		push_warning("PARLEY_WRN: %s" % [message])

	static func error(message: String) -> void:
		push_error("PARLEY_ERR: %s" % [message])
