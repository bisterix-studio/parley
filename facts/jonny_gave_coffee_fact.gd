extends FactInterface

func execute(ctx: Dictionary, _values: Array) -> bool:
	return ctx.get('jonny_gave_coffee', true)
