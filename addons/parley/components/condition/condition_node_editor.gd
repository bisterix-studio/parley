@tool
# TODO: prefix with Parley
class_name ConditionNodeEditor extends NodeEditor

@export var description: String = ""
@export var combiner: ConditionNodeAst.Combiner = ConditionNodeAst.Combiner.ALL
@export var conditions: Array = []

@onready var description_editor: TextEdit = %ConditionDescription
@onready var combiner_option: OptionButton = %CombinerOption
@onready var conditions_editor: VBoxContainer = %Conditions

const condition_scene: PackedScene = preload('./condition.tscn')

signal condition_node_changed(id: String, description: String, combiner: ConditionNodeAst.Combiner, conditions: Array)

func _ready() -> void:
	set_title()
	combiner_option.clear()
	for key: String in ConditionNodeAst.Combiner:
		combiner_option.add_item(key.capitalize(), ConditionNodeAst.Combiner[key])
	update(id, description, combiner, conditions)

# TODO: this is very intertwined - it needs a refactor to use the setter pattern
func update(_id: String, _description: String, _combiner: ConditionNodeAst.Combiner, _conditions: Array) -> void:
	id = _id
	description = _description
	if description_editor:
		description_editor.text = description
	combiner = _combiner
	if combiner_option:
		combiner_option.selected = combiner
	if conditions_editor:
		var condition_children = conditions_editor.get_children()
		for child in condition_children:
			conditions_editor.remove_child(child)
	var conditions_clone = _conditions.duplicate(true)
	conditions = []
	for item: Dictionary in _conditions:
		var _condition: VBoxContainer = add_condition(item['fact_name'], item['operator'], item['value'])

func add_condition(p_fact_name: String = "", p_operator: ConditionNodeAst.Combiner = ConditionNodeAst.Combiner.ALL, p_value: String = "") -> VBoxContainer:
	# TODO: dupe: is this needed?
	# TODO: when we add delete, this will need to be refactored
	var condition_id = conditions.size()
	var new_condition: VBoxContainer = condition_scene.instantiate()
	new_condition.id = condition_id
	new_condition.fact_name = p_fact_name
	new_condition.operator = p_operator
	new_condition.value = p_value
	new_condition.condition_changed.connect(_on_condition_changed)
	conditions.append({
		'fact_name': new_condition.fact_name,
		'operator': new_condition.operator,
		'value': new_condition.value,
	})
	if conditions_editor:
		conditions_editor.add_child(new_condition)
	return new_condition

func emit_condition_node_changed() -> void:
	condition_node_changed.emit(id, description, combiner, conditions)

#region SIGNALS
func _on_condition_description_text_changed() -> void:
	description = description_editor.text
	emit_condition_node_changed()

func _on_add_condition_button_pressed() -> void:
	var _condition: VBoxContainer = add_condition()
	emit_condition_node_changed()

func _on_condition_option_item_selected(_combiner: int) -> void:
	combiner = _combiner as ConditionNodeAst.Combiner
	emit_condition_node_changed()

func _on_condition_changed(condition_id: int, new_fact_name: String, new_operator: ConditionNodeAst.Combiner, new_value: String) -> void:
	# TODO: when we add delete, this will need to be refactored
	conditions[condition_id] = {
		'fact_name': new_fact_name,
		'operator': new_operator,
		'value': new_value,
	}
	emit_condition_node_changed()
#endregion
