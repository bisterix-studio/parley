# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

extends ParleyFactInterface

func evaluate(ctx: ParleyContext, _values: Array) -> String:
	return ctx.p_data.get('alice_coffee_status', 'UNKNOWN_COFFEE_STATUS')


func available_values() -> Array[String]:
	return [
		"NEEDS_COFFEE",
		"NEEDS_MORE_COFFEE",
		"NEEDS_EVEN_MORE_COFFEE",
	]
