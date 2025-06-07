# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

extends FactInterface

func execute(_ctx: Dictionary, _values: Array) -> String:
	print('Alice coffee status')
	return "NEEDS_COFFEE"


func available_values() -> Array[String]:
	return [
		"NEEDS_COFFEE",
		"NEEDS_MORE_COFFEE",
		"NEEDS_EVEN_MORE_COFFEE",
	]
