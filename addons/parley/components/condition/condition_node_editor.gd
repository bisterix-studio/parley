@tool
class_name ConditionNodeEditor extends NodeEditor

@export var description: String = ""
@export var condition: ConditionNodeAst.Combiner = ConditionNodeAst.Combiner.ALL
@export var conditions: Array = []

@onready var description_editor: TextEdit = %ConditionDescription
@onready var condition_option: OptionButton = %ConditionOption
@onready var conditions_editor: VBoxContainer = %Conditions

const condition_scene: PackedScene = preload('./condition.tscn')

signal condition_node_changed

#############
# Lifecycle #
#############
func _ready() -> void:
	condition_option.clear()
	for key in ConditionNodeAst.Combiner:
		condition_option.add_item(key.capitalize(), ConditionNodeAst.Combiner[key])
	update(id, description, condition, conditions)


func update(p_id: String, p_description: String, p_condition: ConditionNodeAst.Combiner, p_conditions: Array) -> void:
	id = p_id
	description = p_description
	description_editor.text = description
	condition = p_condition
	condition_option.selected = condition
	var condition_children = conditions_editor.get_children()
	var conditions_clone = p_conditions.duplicate(true)
	conditions = []
	for child in condition_children:
		conditions_editor.remove_child(child)
	for item in p_conditions:
		add_condition(item['fact_name'], item['operator'], item['value'])


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
	conditions_editor.add_child(new_condition)
	return new_condition


func emit_condition_node_changed() -> void:
	condition_node_changed.emit(id, description, condition, conditions)


#region SIGNALS
func _on_condition_description_text_changed() -> void:
	description = description_editor.text
	emit_condition_node_changed()


func _on_add_condition_button_pressed() -> void:
	add_condition()
	emit_condition_node_changed()


func _on_condition_option_item_selected(p_condition: int) -> void:
	condition = p_condition
	emit_condition_node_changed()


func _on_condition_changed(id: int, new_fact_name: String, new_operator: ConditionNodeAst.Combiner, new_value: String) -> void:
	# TODO: when we add delete, this will need to be refactored
	conditions[id] = {
		'fact_name': new_fact_name,
		'operator': new_operator,
		'value': new_value,
	}
	emit_condition_node_changed()
#endregion
