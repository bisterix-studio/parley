# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

@tool
class_name ParleyConditionNodeAst extends ParleyNodeAst


enum Combiner {ALL, ANY}
enum Operator {EQUAL, NOT_EQUAL}


## The description of the Condition Node AST.
## Example: "Player has an apple"
@export var description: String


## The combiner of the Condition Node AST.
## Example: ConditionCombiner.ALL
@export var combiner: Combiner


## The conditions of the Condition Node AST.
## Example: [{"fact_ref":"res://facts/alice_gave_coffee_fact.gd","operator":Operator.EQUAL,"value":"found"}]
@export var conditions: Array = []


## Create a new instance of a Condition Node AST.
## Example: ParleyConditionNodeAst.new("1", Vector2.ZERO, "Description", ConditionCombiner.ALL, [])
func _init(
	p_id: String = "",
	p_position: Vector2 = Vector2.ZERO,
	p_description: String = "",
	p_condition_combiner: Combiner = Combiner.ALL,
	p_conditions: Array = []
) -> void:
	type = ParleyDialogueSequenceAst.Type.CONDITION
	id = p_id
	position = p_position
	update(p_description, p_condition_combiner, p_conditions)


## Convert this resource into a Dictionary for storage
func to_dict() -> Dictionary:
	var node_dict: Dictionary = inst_to_dict(self)
	var _at_path_discarded: bool = node_dict.erase('@path')
	var _sub_path_discarded: bool = node_dict.erase('@subpath')
	node_dict['combiner'] = str(Combiner.find_key(node_dict['combiner']))
	node_dict['type'] = str(ParleyDialogueSequenceAst.Type.find_key(node_dict['type']))
	return node_dict


## Update a Condition Node AST.
## Example: node.update("Description", ConditionCombiner.ALL, [])
func update(_description: String, _combiner: Combiner, _conditions: Array) -> void:
	description = _description
	combiner = _combiner
	conditions = []
	for _condition: Dictionary in _conditions.duplicate(true):
		var fact_ref: String = _condition['fact_ref']
		var operator: ParleyConditionNodeAst.Operator = _condition['operator']
		var value: Variant = _condition['value']
		add_condition(fact_ref, operator, value)


## Add a condition to the Condition Node AST.
## Example: node.add_condition("uid://123456", Operator.EQUAL, true)
func add_condition(fact_ref: String, operator: Operator, value: Variant) -> void:
	conditions.append({
		# TODO: create type for this
		'fact_ref': fact_ref,
		'operator': operator,
		'value': value,
	})


static func get_colour() -> Color:
	return Color("#737243")
