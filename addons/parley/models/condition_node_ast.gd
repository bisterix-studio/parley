@tool

# TODO: prefix with Parley
class_name ConditionNodeAst extends NodeAst


enum Combiner {ALL, ANY}
enum Operator {EQUAL, NOT_EQUAL}


## The description of the Condition Node AST.
## Example: "Player has an apple"
@export var description: String


## The condition combiner of the Condition Node AST.
## Example: ConditionCombiner.ALL
@export var condition: Combiner


## The conditions of the Condition Node AST.
## Example: [{"fact_ref":"res://facts/alice_gave_coffee_fact.gd","operator":Operator.EQUAL,"value":"found"}]
@export var conditions: Array = []


## Create a new instance of a Condition Node AST.
## Example: ConditionNodeAst.new("1", Vector2.ZERO, "Description", ConditionCombiner.ALL, [])
func _init(
	p_id: String = "",
	p_position: Vector2 = Vector2.ZERO,
	p_description: String = "",
	p_condition_combiner: Combiner = Combiner.ALL,
	p_conditions: Array = []
) -> void:
	type = DialogueAst.Type.CONDITION
	id = p_id
	position = p_position
	update(p_description, p_condition_combiner, p_conditions)


## Convert this resource into a Dictionary for storage
func to_dict() -> Dictionary:
	var node_dict: Dictionary = inst_to_dict(self)
	node_dict.erase('@path')
	node_dict.erase('@subpath')
	node_dict['condition'] = str(Combiner.find_key(node_dict['condition']))
	node_dict['type'] = str(DialogueAst.Type.find_key(node_dict['type']))
	return node_dict


## Update a Condition Node AST.
## Example: node.update("Description", ConditionCombiner.ALL, [])
func update(p_description: String, p_condition_combiner: Combiner, p_conditions: Array) -> void:
	description = p_description
	condition = p_condition_combiner
	conditions = []
	for condition in p_conditions.duplicate(true):
		add_condition(condition['fact_ref'], condition['operator'], condition['value'])


## Add a condition to the Condition Node AST.
## Example: node.add_condition("res://facts/alice_gave_coffee_fact.gd", Operator.EQUAL, true)
func add_condition(fact_ref: String, operator: Operator, value) -> void:
	conditions.append({
		# TODO: create type for this
		'fact_ref': fact_ref,
		'operator': operator,
		'value': value,
	})


static func get_colour() -> Color:
	return Color("#737243")
