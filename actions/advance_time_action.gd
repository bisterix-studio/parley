extends ActionInterface

func execute(_ctx: Dictionary, values: Array) -> void:
	print("Advancing time by %s hours" % [values[0]])
