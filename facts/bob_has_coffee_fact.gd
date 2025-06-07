# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

extends FactInterface

func execute(ctx: Dictionary, _values: Array) -> bool:
	return ctx.get('bob_has_coffee', true)
