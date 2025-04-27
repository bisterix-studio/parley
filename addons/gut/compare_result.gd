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
var _are_equal = false
var are_equal = false:
	get:
		return get_are_equal()
	set(val):
		set_are_equal(val)

var _summary = null
var summary = null:
	get:
		return get_summary()
	set(val):
		set_summary(val)

var _max_differences = 30
var max_differences = 30:
	get:
		return get_max_differences()
	set(val):
		set_max_differences(val)

var _differences = {}
var differences:
	get:
		return get_differences()
	set(val):
		set_differences(val)

func _block_set(which, val):
	push_error(str('cannot set ', which, ', value [', val, '] ignored.'))

func _to_string():
	return str(get_summary()) # could be null, gotta str it.

func get_are_equal():
	return _are_equal

func set_are_equal(r_eq):
	_are_equal = r_eq

func get_summary():
	return _summary

func set_summary(smry):
	_summary = smry

func get_total_count():
	pass

func get_different_count():
	pass

func get_short_summary():
	return summary

func get_max_differences():
	return _max_differences

func set_max_differences(max_diff):
	_max_differences = max_diff

func get_differences():
	return _differences

func set_differences(diffs):
	_block_set('differences', diffs)

func get_brackets():
	return null
