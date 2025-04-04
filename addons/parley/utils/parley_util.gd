@tool
class_name ParleyUtils

## Connect safely to a signal and handle any errors accordingly
static func safe_connect(signal_to_connect: Signal, callable: Callable) -> void:
	var connect_result: int = ERR_INVALID_PARAMETER
	if not signal_to_connect.is_connected(callable):
		connect_result = signal_to_connect.connect(callable)
	if connect_result == ERR_INVALID_PARAMETER:
		log.error("Signal %s already connected" % [signal_to_connect.get_name()])

class log:
	static func info(message: String) -> void:
		print("PARLEY_DBG: %s" % [message])

	static func warn(message: String) -> void:
		push_warning("PARLEY_WRN: %s" % [message])

	static func error(message: String) -> void:
		ParleyUtils.log.error("%s" % [message])
