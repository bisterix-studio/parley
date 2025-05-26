extends ParleyActionInterface

func execute(_ctx: Dictionary, values: Array) -> int:
	print("Found clue: %s" % [values[0]])
	return OK
