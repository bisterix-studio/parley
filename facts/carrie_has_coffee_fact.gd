extends FactInterface

func execute(ctx: Dictionary, _values: Array) -> bool:
	return ctx.get('carrie_has_coffee', true)
