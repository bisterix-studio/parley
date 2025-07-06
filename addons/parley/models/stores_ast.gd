# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

# TODO: for some reason removing this file creates a memory leak in the tests. Keep for now
# and do nothing with it and don't expose it to the user

@tool
class_name StoresAst extends Resource


## The Character Stores for the Dialogue Sequence
var character: Array[ParleyCharacterStore] = []


## The Fact Stores for the Dialogue Sequence
var fact: Array[ParleyFactStore] = []


func _init(_character: Array = [], _fact: Array = []) -> void:
	pass
