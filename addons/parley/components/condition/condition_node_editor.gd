@tool
# TODO: prefix with Parley
class_name ConditionNodeEditor extends NodeEditor


#region DEFS
var fact_store: FactStore: set = _set_fact_store
@export var description: String = ""
@export var combiner: ConditionNodeAst.Combiner = ConditionNodeAst.Combiner.ALL
@export var conditions: Array = []


@onready var description_editor: TextEdit = %ConditionDescription
@onready var combiner_option: OptionButton = %CombinerOption
@onready var conditions_editor: VBoxContainer = %Conditions


const condition_scene: PackedScene = preload('./condition.tscn')


signal condition_node_changed(id: String, description: String, combiner: ConditionNodeAst.Combiner, conditions: Array)
#endregion


#region LIFECYCLE
func _ready() -> void:
	set_title()
	combiner_option.clear()
	for key: String in ConditionNodeAst.Combiner:
		var item_id: int = ConditionNodeAst.Combiner[key]
		combiner_option.add_item(key.capitalize(), item_id)
	update(id, description, combiner, conditions)
#endregion


#region SETTERS
func _set_fact_store(new_fact_store: FactStore) -> void:
	if fact_store != new_fact_store:
		fact_store = new_fact_store
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
		var condition_children: Array[Node] = conditions_editor.get_children()
		for child: Node in condition_children:
			conditions_editor.remove_child(child)
	conditions = []
	for item: Dictionary in _conditions:
		var fact_ref: String = item.get('fact_ref', '')
		var operator: ConditionNodeAst.Operator = item.get('operator', ConditionNodeAst.Operator.EQUAL)
		var value: String = item.get('value', '')
		_add_condition(fact_ref, operator, value)


func _add_condition(p_fact_ref: String = "", p_operator: ConditionNodeAst.Operator = ConditionNodeAst.Operator.EQUAL, p_value: String = "") -> void:
	# TODO: dupe: is this needed?
	# TODO: when we add delete, this will need to be refactored
	var condition_id: String = str(conditions.size())
	var new_condition: ParleyConditionEditor = condition_scene.instantiate()
	new_condition.fact_store = fact_store
	new_condition.id = condition_id
	new_condition.fact_ref = p_fact_ref
	new_condition.operator = p_operator
	new_condition.value = p_value
	ParleyUtils.signals.safe_connect(new_condition.condition_changed, _on_condition_changed)
	ParleyUtils.signals.safe_connect(new_condition.condition_removed, _on_condition_removed)
	conditions.append({
		'fact_ref': new_condition.fact_ref,
		'operator': new_condition.operator,
		'value': new_condition.value,
	})
	if conditions_editor:
		conditions_editor.add_child(HSeparator.new())
		conditions_editor.add_child(new_condition)
#endregion


#region SIGNALS
func _on_condition_description_text_changed() -> void:
	description = description_editor.text
	emit_condition_node_changed()


func _on_add_condition_button_pressed() -> void:
	_add_condition()
	emit_condition_node_changed()


func _on_condition_option_item_selected(_combiner: int) -> void:
	combiner = _combiner as ConditionNodeAst.Combiner
	emit_condition_node_changed()


func _on_condition_changed(condition_id: String, new_fact_ref: String, new_operator: ConditionNodeAst.Combiner, new_value: String) -> void:
	# TODO: when we add delete, this will need to be refactored
	conditions[int(condition_id)] = {
		'fact_ref': new_fact_ref,
		'operator': new_operator,
		'value': new_value,
	}
	emit_condition_node_changed()


func _on_condition_removed(condition_id: String) -> void:
	var index: int = int(condition_id)
	if index < 0 or index >= conditions.size():
		ParleyUtils.log.error("Unable to remove Condition from Condition Node (id:%s, index:%i)" % [id, index])
		return
	conditions.remove_at(int(condition_id))
	update(id, description, combiner, conditions)
	emit_condition_node_changed()


func emit_condition_node_changed() -> void:
	condition_node_changed.emit(id, description, combiner, conditions)
#endregion
