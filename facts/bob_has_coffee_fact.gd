# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

extends ParleyFactInterface

func evaluate(ctx: ParleyContext, _values: Array) -> bool:
	return ctx.p_data.get('bob_has_coffee', true)
