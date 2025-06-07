# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

@tool
class_name ParleyMatchNodeAst extends ParleyNodeAst


## The description of the Match Node AST.
## Example: "Player has an apple"
@export var description: String


## The fact ref of the Match Node AST.
## Example: "uid://123456"
@export var fact_ref: String


## The cases of the Match Node AST.
## Example: ["NEEDS_COFFEE", "NEEDS_MORE_COFFEE", "NEEDS_EVEN_MORE_COFFEE"]
@export var cases: Array[Variant] = []


## Create a new instance of a Match Node AST.
## Example: ParleyMatchNodeAst.new("1", Vector2.ZERO, "Description", "uid://123456", [])
func _init(
	p_id: String = "",
	p_position: Vector2 = Vector2.ZERO,
	p_description: String = "",
	p_fact_ref: String = "",
	p_cases: Array[Variant] = []
) -> void:
	type = ParleyDialogueSequenceAst.Type.MATCH
	id = p_id
	position = p_position
	description = p_description
	fact_ref = p_fact_ref
	cases = []
	cases.append_array(p_cases)

static var fallback_key: String = "FALLBACK"

static var fallback_name: String = "Fallback"

static func get_colour() -> Color:
	return Color("#A8500C")
