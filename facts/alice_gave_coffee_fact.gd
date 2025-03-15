extends FactInterface

func execute(ctx: Dictionary, _values: Array) -> bool:
	return ctx.get('alice_gave_coffee', true)
