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
@warning_ignore_start('UNREACHABLE_CODE')
var things = {}

func get_unique_count():
	return things.size()


func add_thing_to_count(thing):
	if (!things.has(thing)):
		things[thing] = 0


func add(thing):
	if (things.has(thing)):
		things[thing] += 1
	else:
		things[thing] = 1


func has(thing):
	return things.has(thing)


func count(thing):
	var to_return = 0
	if (things.has(thing)):
		to_return = things[thing]
	return to_return


func sum():
	var to_return = 0
	for key in things:
		to_return += things[key]
	return to_return


func to_s():
	var to_return = ""
	for key in things:
		to_return += str(key, ":  ", things[key], "\n")
	to_return += str("sum: ", sum())
	return to_return


func get_max_count():
	var max_val = null
	for key in things:
		if (max_val == null or things[key] > max_val):
			max_val = things[key]
	return max_val


func add_array_items(array):
	for i in range(array.size()):
		add(array[i])
