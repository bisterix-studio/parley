extends ParleyActionInterface

func execute(_ctx: Dictionary, values: Array) -> int:
	print("Advancing time by %s" % [values[0]])
	return OK
