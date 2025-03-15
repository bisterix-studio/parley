extends FactInterface

func execute(ctx: Dictionary, _values: Array) -> bool:
	return ctx.get('bob_has_coffee', true)
