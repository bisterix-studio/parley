@warning_ignore_start('UNTYPED_DECLARATION')
@warning_ignore_start('INFERRED_DECLARATION')
@warning_ignore_start('UNSAFE_METHOD_ACCESS')
@warning_ignore_start('UNSAFE_CALL_ARGUMENT')
@warning_ignore_start('RETURN_VALUE_DISCARDED')
@warning_ignore_start('SHADOWED_VARIABLE')
@warning_ignore_start('UNUSED_VARIABLE')
@warning_ignore_start('UNSAFE_PROPERTY_ACCESS')
@warning_ignore_start('UNUSED_PARAMETER')
@warning_ignore_start('UNUSED_PRIVATE_CLASS_VARIABLE')
@warning_ignore_start('SHADOWED_VARIABLE_BASE_CLASS')
@warning_ignore_start('UNUSED_SIGNAL')
@warning_ignore_start('INTEGER_DIVISION')
var _params = null
var _call_count = 0
var _logger = null

func _init(params = null):
	_params = params
	_logger = GutUtils.get_logger()
	if (typeof(_params) != TYPE_ARRAY):
		_logger.error('You must pass an array to parameter_handler constructor.')
		_params = null


func next_parameters():
	_call_count += 1
	return _params[_call_count - 1]

func get_current_parameters():
	return _params[_call_count]

func is_done():
	var done = true
	if (_params != null):
		done = _call_count == _params.size()
	return done

func get_logger():
	return _logger

func set_logger(logger):
	_logger = logger

func get_call_count():
	return _call_count

func get_parameter_count():
	return _params.size()
