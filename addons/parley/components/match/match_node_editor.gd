# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

@tool
class_name ParleyMatchNodeEditor extends ParleyBaseNodeEditor


#region DEFS
var fact_store: ParleyFactStore = ParleyFactStore.new(): set = _set_fact_store
var description: String = "": set = _set_description
var fact_ref: String = "": set = _set_fact_ref
var cases: Array[Variant] = []: set = _set_cases


@onready var description_editor: TextEdit = %MatchDescription
@onready var fact_selector: OptionButton = %FactSelector
@onready var cases_editor: VBoxContainer = %CasesEditor
@onready var add_case_button: Button = %AddCaseButton
@onready var add_fallback_case_button: Button = %AddFallbackCaseButton


const case_editor: PackedScene = preload("./case.tscn")


var available_cases: Array[Variant] = [ParleyMatchNodeAst.fallback_key]
var has_fallback: bool = false: set = _on_set_has_fallback


signal match_node_changed(id: String, description: String, fact_ref: String, cases: Array[Variant])
#endregion


#region LIFECYCLE
func _ready() -> void:
	set_title()
	_render_description()
	_render_fact_options()
	_render_cases()
	if fact_store:
		ParleyUtils.signals.safe_connect(fact_store.changed, _on_fact_store_changed)
#endregion


#region SETTERS
func _set_fact_store(new_fact_store: ParleyFactStore) -> void:
	fact_store = new_fact_store
	if fact_store != new_fact_store:
		if fact_store:
			ParleyUtils.signals.safe_disconnect(fact_store.changed, _on_fact_store_changed)
		fact_store = new_fact_store
		if fact_store:
			ParleyUtils.signals.safe_connect(fact_store.changed, _on_fact_store_changed)
	_render_fact_options()


func _set_description(new_description: String) -> void:
	description = new_description
	_render_description()


func _on_set_has_fallback(_has_fallback: bool) -> void:
	has_fallback = _has_fallback
	if add_fallback_case_button:
		add_fallback_case_button.disabled = has_fallback


func _set_fact_ref(new_fact_ref: String) -> void:
	fact_ref = new_fact_ref
	_render_fact()
	var fact: ParleyFact = fact_store.get_fact_by_ref(fact_ref)
	if fact_store and fact.id != "":
		var script: GDScript = load(fact_ref)
		if script is not GDScript:
			push_error(ParleyUtils.log.error_msg("Fact is not valid GDScript (def:%s)" % fact))
			return
		var fact_interface: ParleyFactInterface = script.new()
		if fact_interface is not ParleyFactInterface or not fact_interface.has_method(&"evaluate"):
			push_error(ParleyUtils.log.error_msg("Fact script is not a valid Fact interface (def:%s, fact:%s)" % [fact, fact_interface]))
			return
		var new_available_cases: Array[Variant] = []
		new_available_cases.append_array(fact_interface.available_values())
		# TODO: create a wrapper for this
		fact_interface.free()
		new_available_cases.append(ParleyMatchNodeAst.fallback_key)
		available_cases = new_available_cases
		var filtered_cases: Array[Variant] = []
		for case: Variant in cases:
			if available_cases.size() == 1 or available_cases.has(case):
				filtered_cases.append(case)
		cases = filtered_cases


func _set_cases(new_cases: Array[Variant]) -> void:
	# TODO: move to helper
	var keys: Dictionary = {}
	for case: Variant in new_cases:
		if not case in keys:
			keys[case] = case
	var filtered_cases: Array[Variant] = []
	for key: Variant in keys.keys():
		filtered_cases.append(key)
	if filtered_cases.hash() == cases.hash():
		return
	cases = filtered_cases
	_render_cases()
#endregion


#region RENDERERS
func _render_description() -> void:
	if description_editor and description_editor.text != description:
		description_editor.text = description


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
	if fact_store and fact_selector:
		var selected_index: int = fact_store.get_fact_index_by_ref(fact_ref)
		if fact_selector.selected != selected_index and selected_index < fact_selector.item_count:
			fact_selector.select(selected_index)


func _render_cases() -> void:
	if cases_editor:
		for child: Node in cases_editor.get_children():
			if child is ParleyCaseEditor:
				cases_editor.remove_child(child)
				child.queue_free()
		var index: int = 0
		var _has_fallback: bool = false
		for case: Variant in cases:
			var case_inst: ParleyCaseEditor = case_editor.instantiate()
			case_inst.available_cases = available_cases
			case_inst.value = case
			if case is String and case == ParleyMatchNodeAst.fallback_key:
				case_inst.value = ParleyMatchNodeAst.fallback_key
				case_inst.is_fallback = true
				_has_fallback = true
			else:
				case_inst.value = case

			ParleyUtils.signals.safe_connect(case_inst.case_edited, _on_case_edited.bind(index))
			ParleyUtils.signals.safe_connect(case_inst.case_deleted, _on_case_deleted.bind(index))
			cases_editor.add_child(case_inst)
			index += 1
		has_fallback = _has_fallback
#endregion


#region SIGNALS
func _on_case_edited(value: String, is_fallback: bool, index: int) -> void:
	cases[index] = ParleyMatchNodeAst.fallback_key if is_fallback else value
	_emit_match_node_changed()


func _on_case_deleted(index: int) -> void:
	var new_cases: Array[Variant] = cases.duplicate()
	new_cases.remove_at(index)
	cases = new_cases
	_emit_match_node_changed()


func _on_match_description_text_changed() -> void:
	description = description_editor.text
	_emit_match_node_changed()


func _on_fact_selector_item_selected(index: int) -> void:
	if index == -1 or index >= fact_store.facts.size():
		return
	var fact: ParleyFact = fact_store.facts[index]
	fact_ref = ParleyUtils.resource.get_uid(fact.ref)
	_emit_match_node_changed()


func _on_add_case_button_pressed() -> void:
	var new_cases: Array[Variant] = cases.duplicate()
	var next_case: Variant
	for case: Variant in available_cases:
		if case not in cases:
			next_case = case
			break
	new_cases.append(next_case)
	cases = new_cases
	_emit_match_node_changed()


func _on_add_fallback_case_button_pressed() -> void:
	var new_cases: Array[Variant] = cases.duplicate()
	new_cases.append(ParleyMatchNodeAst.fallback_key)
	cases = new_cases
	_emit_match_node_changed()


func _on_fact_store_changed() -> void:
	_render_fact_options()


func _on_edit_fact_button_pressed() -> void:
	if not fact_store:
		return
	var fact: ParleyFact = fact_store.get_fact_by_ref(fact_ref)
	if fact.ref is Script:
		var script: Script = fact.ref
		EditorInterface.edit_script(script)
		EditorInterface.set_main_screen_editor('Script')


func _emit_match_node_changed() -> void:
	match_node_changed.emit(id, description, fact_ref, cases)
#endregion
