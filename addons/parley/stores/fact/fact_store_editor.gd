# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

@tool
class_name ParleyFactStoreEditor extends PanelContainer


#region DEFS
const FactEditor: PackedScene = preload("../../components/fact/fact_editor.tscn")


var parley_manager: ParleyManager
var fact_store: ParleyFactStore = ParleyFactStore.new(): set = _set_fact_store
var dialogue_sequence_ast: ParleyDialogueSequenceAst: set = _set_dialogue_sequence_ast
var fact_filter: String = "": set = _set_fact_filter
var facts: Array[ParleyFact] = []: set = _set_facts
var filtered_facts: Array[ParleyFact] = []


@onready var facts_container: VBoxContainer = %FactsContainer
@onready var fact_store_editor: ParleyResourceEditor = %FactStore
@onready var dialogue_sequence_container: ParleyResourceEditor = %DialogueSequenceContainer
@onready var add_fact_button: Button = %AddFactButton
@onready var save_fact_store_button: Button = %SaveFactStoreButton
@onready var invalid_fact_store_button: Button = %InvalidFactStoreButton
@onready var new_fact_store_button: Button = %NewFactStoreButton
@onready var register_fact_store_modal: ParleyRegisterStoreModal = %RegisterFactStoreModal


signal dialogue_sequence_ast_selected(dialogue_sequence_ast: ParleyDialogueSequenceAst)
signal dialogue_sequence_ast_changed(dialogue_sequence_ast: ParleyDialogueSequenceAst)
signal fact_store_changed(fact_store: ParleyFactStore)
#endregion


#region LIFECYCLE
func _ready() -> void:
	fact_store_editor.resource = fact_store
	facts = fact_store.facts
	_render()


func _clear_facts() -> void:
	for child: Node in facts_container.get_children():
		child.queue_free()
#endregion


#region SETTERS
func _set_dialogue_sequence_ast(new_dialogue_sequence_ast: ParleyDialogueSequenceAst) -> void:
	if dialogue_sequence_ast != new_dialogue_sequence_ast:
		dialogue_sequence_ast = new_dialogue_sequence_ast
		_reload_dialogue_sequence_ast()


func _reload_dialogue_sequence_ast() -> void:
	_render_dialogue_sequence()


func _set_fact_store(new_fact_store: ParleyFactStore) -> void:
	if fact_store != new_fact_store:
		fact_store = new_fact_store
		if fact_store_editor.resource != fact_store:
			fact_store_editor.resource = fact_store
		if fact_store:
			facts = fact_store.facts
		else:
			facts = []
		fact_store_changed.emit(fact_store)
	_render_save_fact_store_button()
	_render_invalid_fact_store_button()

func _set_facts(new_facts: Array[ParleyFact]) -> void:
	facts = new_facts
	filtered_facts = []
	for fact: ParleyFact in facts:
		var raw_fact_string: String = str(inst_to_dict(fact))
		if not fact_filter or raw_fact_string.containsn(fact_filter):
			filtered_facts.append(fact)
	_render_facts()
	if fact_store:
		fact_store.emit_changed()


func _set_fact_filter(new_fact_filter: String) -> void:
	fact_filter = new_fact_filter
	_set_facts(facts)
#endregion


#region RENDERERS
func _render() -> void:
	_render_fact_store_editor()
	_render_dialogue_sequence()
	_render_add_fact_button()
	_render_new_fact_store_button()
	_render_save_fact_store_button()
	_render_invalid_fact_store_button()
	_render_facts()

func _render_dialogue_sequence() -> void:
	if dialogue_sequence_container and dialogue_sequence_ast and dialogue_sequence_ast.resource_path:
		dialogue_sequence_container.base_type = ParleyDialogueSequenceAst.type_name
		dialogue_sequence_container.resource = dialogue_sequence_ast


func _render_add_fact_button() -> void:
	if add_fact_button:
		add_fact_button.tooltip_text = "Add Fact to the currently selected store."


func _render_fact_store_editor() -> void:
	if fact_store_editor and (not fact_store or not fact_store.resource_path):
		fact_store_editor.resource = null


func _render_save_fact_store_button() -> void:
	if save_fact_store_button:
		save_fact_store_button.tooltip_text = "Save Fact Store."
		if not fact_store or not fact_store.resource_path:
			save_fact_store_button.hide()
		else:
			save_fact_store_button.show()


func _render_invalid_fact_store_button() -> void:
	if invalid_fact_store_button:
		invalid_fact_store_button.tooltip_text = "Invalid Fact Store because it does not contain a resource path, please rectify or create and register a new Fact Store."
		if fact_store and fact_store.resource_path:
			invalid_fact_store_button.hide()
		else:
			invalid_fact_store_button.show()


func _render_new_fact_store_button() -> void:
	if new_fact_store_button:
		new_fact_store_button.tooltip_text = "Create and register new Fact Store."


func _render_facts() -> void:
	if facts_container:
		_clear_facts()
		var index: int = 0
		for fact: ParleyFact in filtered_facts:
			var fact_editor: ParleyFactEditor = FactEditor.instantiate()
			fact_editor.fact_id = fact.id
			fact_editor.fact_name = fact.name
			fact_editor.fact_ref = fact.ref
			ParleyUtils.signals.safe_connect(fact_editor.fact_changed, _on_fact_changed.bind(fact))
			ParleyUtils.signals.safe_connect(fact_editor.fact_removed, _on_fact_removed.bind(fact))
			facts_container.add_child(fact_editor)
			if index != filtered_facts.size() - 1:
				var horizontal_separator: HSeparator = HSeparator.new()
				facts_container.add_child(horizontal_separator)
			index += 1
#endregion


#region SIGNALS
func _on_fact_changed(new_id: String, new_name: String, new_resource: Resource, fact: ParleyFact) -> void:
	fact.id = new_id
	fact.name = new_name
	fact.ref = new_resource
	if fact_store:
		fact_store.emit_changed()


func _on_fact_removed(fact_id: String, _fact: ParleyFact) -> void:
	fact_store.remove_fact(fact_id)
	facts = fact_store.facts


func _on_add_fact_button_pressed() -> void:
	var _new_fact: ParleyFact = fact_store.add_fact()
	facts = fact_store.facts


func _on_filter_facts_text_changed(new_fact_filter: String) -> void:
	fact_filter = new_fact_filter


func _on_save_fact_store_button_pressed() -> void:
	_save()


func _on_new_fact_store_button_pressed() -> void:
	register_fact_store_modal.show()
	register_fact_store_modal.clear()
	register_fact_store_modal.file_mode = FileDialog.FileMode.FILE_MODE_SAVE_FILE
	register_fact_store_modal.resource_editor.resource = ParleyFactStore.new()
	# TODO: get from config
	register_fact_store_modal.path_edit.text = "res://facts/new_fact_store.tres"
	register_fact_store_modal.id_valid = true
	register_fact_store_modal.script_valid = true
	register_fact_store_modal.resource_exists = true


func _on_dialogue_sequence_container_resource_changed(new_dialogue_sequence_ast: Resource) -> void:
	if new_dialogue_sequence_ast is ParleyDialogueSequenceAst:
		dialogue_sequence_ast = new_dialogue_sequence_ast
		dialogue_sequence_ast_changed.emit(dialogue_sequence_ast)


func _on_dialogue_sequence_container_resource_selected(selected_dialogue_sequence_ast: Resource, _inspect: bool) -> void:
	if dialogue_sequence_ast is ParleyDialogueSequenceAst:
		dialogue_sequence_ast_selected.emit(selected_dialogue_sequence_ast)


func _on_register_fact_store_modal_store_registered(store: ParleyStore) -> void:
	_register_fact_store(store, true)


func _on_fact_store_resource_changed(store: Resource) -> void:
	if store is ParleyFactStore:
		_register_fact_store(store as ParleyFactStore, true)
	else:
		fact_store = null
#endregion


#region ACTIONS
func _register_fact_store(store: ParleyStore, new: bool) -> void:
	if store is ParleyFactStore:
		fact_store = store
		if new and parley_manager:
			parley_manager.register_fact_store(fact_store)
		_render()


func _save() -> void:
	var result: int = ResourceSaver.save(fact_store)
	if result != OK:
		push_error(ParleyUtils.log.error_msg("Error saving fact store [ID: %s]. Code: %d" % [fact_store.id, result]))
		return
#endregion
