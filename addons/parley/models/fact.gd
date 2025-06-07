# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

@tool
class_name ParleyFact extends Resource

# TODO: make a string
## The unique ID of the Fact. It is unique within the scope of the Parley plugin
## Example: "1"
@export var id: String


## The unique name of the Fact.
## Example: "alice_gave_coffee"
@export var name: String


## The ref script of the Fact.
## Example: "res://facts/alice_gave_coffee_fact.gd"
@export var ref: Resource


func _init(p_id: String = "", p_name: String = "", p_ref: Resource = null) -> void:
	id = p_id
	name = p_name
	ref = p_ref


func _to_string() -> String:
	return "ParleyFact<id=%s name=%s ref=%s>" % [id || "Unknown", name || "Unknown", ref || "Unknown"]
