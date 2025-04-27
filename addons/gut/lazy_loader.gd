@tool
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
# ------------------------------------------------------------------------------
# Static
# ------------------------------------------------------------------------------
static var usage_counter = load('res://addons/gut/thing_counter.gd').new()
static var WarningsManager = load('res://addons/gut/warnings_manager.gd')

static func load_all():
	for key in usage_counter.things:
		key.get_loaded()


static func print_usage():
	for key in usage_counter.things:
		print(key._path, '  (', usage_counter.things[key], ')')


# ------------------------------------------------------------------------------
# Class
# ------------------------------------------------------------------------------
var _loaded = null
var _path = null

func _init(path):
	_path = path
	usage_counter.add_thing_to_count(self)


func get_loaded():
	if (_loaded == null):
		_loaded = WarningsManager.load_script_ignoring_all_warnings(_path)
	usage_counter.add(self)
	return _loaded
