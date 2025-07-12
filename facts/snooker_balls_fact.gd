# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

extends ParleyFactInterface

enum Ball {
	RED = 1,
	YELLOW = 2,
	PINK = 6,
	BLUE = 5,
}

func evaluate(ctx: ParleyContext, _values: Array) -> int:
	return ctx.p_data.get('ball', 0)

func available_values() -> Array[Ball]:
	return [
		Ball.RED,
		Ball.YELLOW,
		Ball.PINK,
		Ball.BLUE,
	]
