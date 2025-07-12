# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

class_name ParleyFactInterface extends Object


func evaluate(ctx: ParleyContext, values: Array) -> Variant:
	push_error(ParleyUtils.log.error_msg('Fact not implemented (ctx:%s, values:%s)' % [ctx, values]))
	return


func available_values() -> Array[Variant]:
	return []
