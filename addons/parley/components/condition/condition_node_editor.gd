# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

@tool
class_name ParleyConditionNodeEditor extends ParleyBaseNodeEditor


#region DEFS
var fact_store: ParleyFactStore: set = _set_fact_store
@export var description: String = "": set = _set_description
@export var combiner: ParleyConditionNodeAst.Combiner = ParleyConditionNodeAst.Combiner.ALL: set = _set_combiner
@export var conditions: Array = []: set = _set_conditions


@onready var description_editor: TextEdit = %ConditionDescription
@onready var combiner_option: OptionButton = %CombinerOption
@onready var conditions_editor: VBoxContainer = %Conditions


const condition_scene: PackedScene = preload('./condition_editor.tscn')


signal condition_node_changed(id: String, description: String, combiner: ParleyConditionNodeAst.Combiner, conditions: Array)
#endregion


#region LIFECYCLE
func _ready() -> void:
	set_title()
	_render_description()
	_render_combiner_options()
	_render_combiner()
	_render_conditions()
#endregion


#region SETTERS
func _set_description(new_description: String) -> void:
	description = new_description
	_render_description()


func _set_combiner(new_combiner: ParleyConditionNodeAst.Combiner) -> void:
	combiner = new_combiner
	_render_combiner()


func _set_conditions(new_conditions: Array) -> void:
	conditions = []
	for condition: Dictionary in new_conditions:
		var fact_ref: String = condition.get('fact_ref', '')
		var operator: ParleyConditionNodeAst.Operator = condition.get('operator', ParleyConditionNodeAst.Operator.EQUAL)
		var value: String = condition.get('value', '')
		conditions.append({
			'fact_ref': condition.fact_ref,
			'operator': condition.operator,
			'value': condition.value,
		})
	_render_conditions()


func _set_fact_store(new_fact_store: ParleyFactStore) -> void:
	if fact_store != new_fact_store:
		fact_store = new_fact_store
		conditions = conditions.duplicate(true)
#endregion


#region RENDERERS
func _render_description() -> void:
	if description_editor and description_editor.text != description:
		description_editor.text = description


func _render_combiner() -> void:
	if combiner_option:
		combiner_option.selected = combiner


func _render_combiner_options() -> void:
	if combiner_option:
		combiner_option.clear()
		for key: String in ParleyConditionNodeAst.Combiner:
			var item_id: int = ParleyConditionNodeAst.Combiner[key]
			combiner_option.add_item(key.capitalize(), item_id)


func _render_conditions() -> void:
	if conditions_editor:
		var condition_children: Array[Node] = conditions_editor.get_children()
		for child: Node in condition_children:
			conditions_editor.remove_child(child)
			child.queue_free()
		var index: int = 0
		for condition: Dictionary in conditions:
			var fact_ref: String = condition.get('fact_ref', '')
			var operator: ParleyConditionNodeAst.Operator = condition.get('operator', ParleyConditionNodeAst.Operator.EQUAL)
			var value: String = condition.get('value', '')
			var new_condition: ParleyConditionEditor = condition_scene.instantiate()
			new_condition.fact_store = fact_store
			new_condition.id = str(index)
			# TODO: use setter pattern
			new_condition.fact_ref = fact_ref
			new_condition.operator = operator
			new_condition.value = value
			ParleyUtils.signals.safe_connect(new_condition.condition_changed, _on_condition_changed)
			ParleyUtils.signals.safe_connect(new_condition.condition_removed, _on_condition_removed)
			conditions_editor.add_child(new_condition)
			if index != conditions.size() - 1:
				conditions_editor.add_child(HSeparator.new())
			index += 1
#endregion


#region SIGNALS
func _on_condition_description_text_changed() -> void:
	description = description_editor.text
	emit_condition_node_changed()


func _on_add_condition_button_pressed() -> void:
	var new_conditions: Array = conditions.duplicate(true)
	new_conditions.append({
		'fact_ref': "",
		'operator': ParleyConditionNodeAst.Operator.EQUAL,
		'value': "",
	})
	conditions = new_conditions
	emit_condition_node_changed()


func _on_condition_option_item_selected(new_combiner: int) -> void:
	combiner = new_combiner as ParleyConditionNodeAst.Combiner
	emit_condition_node_changed()


func _on_condition_changed(condition_id: String, new_fact_ref: String, new_operator: ParleyConditionNodeAst.Combiner, new_value: String) -> void:
	conditions[int(condition_id)] = {
		'fact_ref': new_fact_ref,
		'operator': new_operator,
		'value': new_value,
	}
	emit_condition_node_changed()


func _on_condition_removed(condition_id: String) -> void:
	var index: int = int(condition_id)
	var new_conditions: Array = conditions.duplicate(true)
	if index < 0 or index >= new_conditions.size():
		push_error(ParleyUtils.log.error_msg("Unable to remove Condition from Condition Node (id:%s, index:%i)" % [id, index]))
		return
	new_conditions.remove_at(int(condition_id))
	conditions = new_conditions
	emit_condition_node_changed()


func emit_condition_node_changed() -> void:
	condition_node_changed.emit(id, description, combiner, conditions)
#endregion
