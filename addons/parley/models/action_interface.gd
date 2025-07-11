# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

class_name ParleyActionInterface extends Object


func run(ctx: ParleyContext, values: Array) -> int:
	push_error('PARLEY_ERR: Action not implemented (ctx:%s, values:%s)' % [ctx, values])
	return FAILED
