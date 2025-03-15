@tool
class_name MatchNodeAst extends NodeAst


## The description of the Match Node AST.
## Example: "Player has an apple"
@export var description: String


## The condition combiner of the Match Node AST.
## Example: "res://facts/alice_coffee_status_fact.gd"
@export var fact_ref: String


## The conditions of the Match Node AST.
## Example: ["NEEDS_COFFEE", "NEEDS_MORE_COFFEE", "NEEDS_EVEN_MORE_COFFEE"]
@export var cases: Array[Variant] = []


## Create a new instance of a Match Node AST.
## Example: MatchNodeAst.new("1", Vector2.ZERO, "Description", "res://facts/alice_coffee_status_fact.gd", [])
func _init(
	p_id: String = "",
	p_position: Vector2 = Vector2.ZERO,
	p_description: String = "",
	p_fact_ref: String = "",
	p_cases: Array[Variant] = []
) -> void:
	type = DialogueAst.Type.MATCH
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
