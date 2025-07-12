# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

extends ParleyActionInterface

func run(_ctx: ParleyContext, values: Array) -> int:
	print("Found clue: %s" % [values[0]])
	return OK
