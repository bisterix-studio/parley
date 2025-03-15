extends FactInterface

func execute(_ctx: Dictionary, _values: Array) -> String:
	print('Jonny coffee status')
	return "NEEDS_COFFEE"


func available_values() -> Array[String]:
	return [
		"NEEDS_COFFEE",
		"NEEDS_MORE_COFFEE",
		"NEEDS_EVEN_MORE_COFFEE",
	]
