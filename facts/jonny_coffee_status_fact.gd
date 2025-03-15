extends FactInterface

func execute(ctx: Dictionary, _values: Array) -> String:
	return ctx.get('jonny_coffee_status', 'UNKNOWN_COFFEE_STATUS')


func available_values() -> Array[String]:
	return [
		"NEEDS_COFFEE",
		"NEEDS_MORE_COFFEE",
		"NEEDS_EVEN_MORE_COFFEE",
	]
