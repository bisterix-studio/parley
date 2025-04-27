class_name FactInterface extends Object

func execute(_ctx: Dictionary, _values: Array) -> Variant:
	push_error('PARLEY_ERR: Fact not implemented')
	return


func available_values() -> Array[Variant]:
	return []
