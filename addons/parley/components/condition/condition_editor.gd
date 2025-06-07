# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

@tool

class_name ParleyConditionEditor extends PanelContainer


#region DEFS
@export var fact_store: ParleyFactStore: set = _set_fact_store
@export var id: String = ""
@export var fact_ref: String = "": set = _set_fact_ref
@export var operator: ParleyConditionNodeAst.Operator = ParleyConditionNodeAst.Operator.EQUAL
@export var value: String = ""


@onready var fact_selector: OptionButton = %FactSelector
@onready var operator_editor: OptionButton = %OperatorEditor
@onready var value_editor: ParleyStringEditor = %ValueEditor


signal condition_changed(id: String, fact_ref: String, operator: ParleyConditionNodeAst.Operator, value: String)
signal condition_removed(id: String)
#endregion


#region LIFECYCLE
func _ready() -> void:
	_render_fact_options()
	_render_operator_options()
	update(fact_ref, operator, value)
	if fact_store:
		ParleyUtils.signals.safe_connect(fact_store.changed, _on_fact_store_changed)
#endregion


#region SETTERS
func update(p_fact_ref: String, p_operator: ParleyConditionNodeAst.Operator, p_value: String) -> void:
	fact_ref = p_fact_ref
	operator = p_operator
	value = p_value
	_render_fact()
	_render_operator()
	_render_value()


func _set_fact_ref(new_fact_ref: String) -> void:
	fact_ref = new_fact_ref
	_render_fact()


func _set_fact_store(new_fact_store: ParleyFactStore) -> void:
	fact_store = new_fact_store
	if fact_store != new_fact_store:
		if fact_store:
			ParleyUtils.signals.safe_disconnect(fact_store.changed, _on_fact_store_changed)
		fact_store = new_fact_store
		if fact_store:
			ParleyUtils.signals.safe_connect(fact_store.changed, _on_fact_store_changed)
	_render_fact_options()
#endregion


#region RENDERERS
func _render_fact_options() -> void:
	if not fact_selector:
		return
	fact_selector.clear()
	if not fact_store:
		return
	for fact: ParleyFact in fact_store.facts:
		fact_selector.add_item(fact.name)
	_render_fact()


func _render_fact() -> void:
	if fact_selector and fact_store:
		var selected_index: int = fact_store.get_fact_index_by_ref(fact_ref)
		if fact_selector.selected != selected_index:
			fact_selector.select(selected_index)


func _render_operator_options() -> void:
	if operator_editor:
		operator_editor.clear()
		for key: String in ParleyConditionNodeAst.Operator:
			var item_id: int = ParleyConditionNodeAst.Operator[key]
			operator_editor.add_item(key.capitalize(), item_id)


func _render_operator() -> void:
	if operator_editor:
		operator_editor.selected = operator


func _render_value() -> void:
	if value_editor:
		value_editor.value = value
#endregion


#region SIGNALS
func _on_operator_editor_item_selected(selected_operator: int) -> void:
	operator = selected_operator as ParleyConditionNodeAst.Operator
	_emit_condition_changed()


func _on_value_editor_value_changed(new_value: String) -> void:
	value = new_value
	_emit_condition_changed()


func _on_fact_selector_item_selected(index: int) -> void:
	if index == -1 or index >= fact_store.facts.size():
		return
	var fact: ParleyFact = fact_store.facts[index]
	fact_ref = ParleyUtils.resource.get_uid(fact.ref)
	_emit_condition_changed()


func _on_edit_fact_button_pressed() -> void:
	if not fact_store:
		return
	var fact: ParleyFact = fact_store.get_fact_by_ref(fact_ref)
	if fact.ref is Script:
		var script: Script = fact.ref
		EditorInterface.edit_script(script)
		EditorInterface.set_main_screen_editor('Script')


func _on_fact_store_changed() -> void:
	_render_fact_options()


func _on_delete_button_pressed() -> void:
	condition_removed.emit(id)


func _emit_condition_changed() -> void:
	condition_changed.emit(id, fact_ref, operator, value)
#endregion
