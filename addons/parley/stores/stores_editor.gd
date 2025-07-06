# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

@tool
class_name ParleyStoresEditor extends PanelContainer


#region DEFS
var action_store: ParleyActionStore: set = _set_action_store
var fact_store: ParleyFactStore: set = _set_fact_store
var character_store: ParleyCharacterStore: set = _set_character_store

@onready var show_character_store_button: Button = %ShowCharacterStoreButton
@onready var show_fact_store_button: Button = %ShowFactStoreButton
@onready var show_action_store_button: Button = %ShowActionStoreButton
@onready var character_store_editor: ParleyCharacterStoreEditor = %CharacterStoreEditor
@onready var fact_store_editor: ParleyFactStoreEditor = %FactStoreEditor
@onready var action_store_editor: ParleyActionStoreEditor = %ActionStoreEditor


enum Store {
	CHARACTER,
	FACT,
	ACTION,
}


var parley_manager: ParleyManager
var dialogue_ast: ParleyDialogueSequenceAst = ParleyDialogueSequenceAst.new(): set = _set_dialogue_ast
var current_store: Store: set = _set_current_store


signal dialogue_sequence_ast_selected(dialogue_sequence_ast: ParleyDialogueSequenceAst)
signal dialogue_sequence_ast_changed(dialogue_sequence_ast: ParleyDialogueSequenceAst)
signal store_changed(type: ParleyStore.Type, store: ParleyStore)
#endregion


#region LIFECYCLE
func _ready() -> void:
	character_store_editor.parley_manager = parley_manager
	fact_store_editor.parley_manager = parley_manager
	action_store_editor.parley_manager = parley_manager
	current_store = Store.CHARACTER
	ParleyUtils.signals.safe_connect(action_store_editor.action_store_changed, _on_action_store_changed)
	ParleyUtils.signals.safe_connect(fact_store_editor.fact_store_changed, _on_fact_store_changed)
	ParleyUtils.signals.safe_connect(character_store_editor.character_store_changed, _on_character_store_changed)


func _exit_tree() -> void:
	ParleyUtils.signals.safe_disconnect(action_store_editor.action_store_changed, _on_action_store_changed)
	ParleyUtils.signals.safe_disconnect(fact_store_editor.fact_store_changed, _on_fact_store_changed)
	ParleyUtils.signals.safe_disconnect(character_store_editor.character_store_changed, _on_character_store_changed)
#endregion


#region SETTERS
func _set_action_store(new_action_store: ParleyActionStore) -> void:
	action_store = new_action_store
	_set_current_store(current_store)


func _set_fact_store(new_fact_store: ParleyFactStore) -> void:
	fact_store = new_fact_store
	_set_current_store(current_store)


func _set_character_store(new_character_store: ParleyCharacterStore) -> void:
	character_store = new_character_store
	_set_current_store(current_store)


func _set_dialogue_ast(new_dialogue_ast: ParleyDialogueSequenceAst) -> void:
	if dialogue_ast != new_dialogue_ast:
		dialogue_ast = new_dialogue_ast
		_set_current_store(current_store)


func _set_current_store(new_current_store: Store) -> void:
	current_store = new_current_store
	match current_store:
		Store.CHARACTER: _render_character_store()
		Store.FACT: _render_fact_store()
		Store.ACTION: _render_action_store()
		_: push_error('PARLEY_ERR: Unsupported store selected: %s' % [current_store])


func _render_character_store() -> void:
	if show_character_store_button and not show_character_store_button.button_pressed:
		show_character_store_button.button_pressed = true
	_clear()
	if character_store_editor:
		character_store_editor.character_store = character_store
		if character_store_editor.dialogue_sequence_ast != dialogue_ast:
			character_store_editor.dialogue_sequence_ast = dialogue_ast
		character_store_editor.show()


func _render_fact_store() -> void:
	if show_fact_store_button and not show_fact_store_button.button_pressed:
		show_fact_store_button.button_pressed = true
	_clear()
	if fact_store_editor:
		fact_store_editor.fact_store = fact_store
		if fact_store_editor.dialogue_sequence_ast != dialogue_ast:
			fact_store_editor.dialogue_sequence_ast = dialogue_ast
		fact_store_editor.show()


func _render_action_store() -> void:
	if show_action_store_button and not show_action_store_button.button_pressed:
		show_action_store_button.button_pressed = true
	_clear()
	if action_store_editor:
		action_store_editor.action_store = action_store
		if action_store_editor.dialogue_sequence_ast != dialogue_ast:
			action_store_editor.dialogue_sequence_ast = dialogue_ast
		action_store_editor.show()
#endregion


#region RENDERERS
func _clear() -> void:
	if character_store_editor:
		character_store_editor.hide()
	if fact_store_editor:
		fact_store_editor.hide()
	if action_store_editor:
		action_store_editor.hide()


func _render() -> void:
	_clear()
#endregion


#region SIGNALS
func _on_action_store_changed(new_action_store: ParleyActionStore) -> void:
	store_changed.emit(ParleyStore.Type.Action, new_action_store)


func _on_fact_store_changed(new_fact_store: ParleyFactStore) -> void:
	store_changed.emit(ParleyStore.Type.Fact, new_fact_store)


func _on_character_store_changed(new_character_store: ParleyCharacterStore) -> void:
	store_changed.emit(ParleyStore.Type.Character, new_character_store)


func _on_show_character_store_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		current_store = Store.CHARACTER
		if show_fact_store_button:
			show_fact_store_button.button_pressed = false
		if show_action_store_button:
			show_action_store_button.button_pressed = false


func _on_show_fact_store_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		current_store = Store.FACT
		if show_character_store_button:
			show_character_store_button.button_pressed = false
		if show_action_store_button:
			show_action_store_button.button_pressed = false


func _on_show_action_store_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		current_store = Store.ACTION
		if show_fact_store_button:
			show_fact_store_button.button_pressed = false
		if show_character_store_button:
			show_character_store_button.button_pressed = false


func _on_fact_store_editor_dialogue_sequence_ast_changed(new_dialogue_sequence_ast: ParleyDialogueSequenceAst) -> void:
	dialogue_sequence_ast_changed.emit(new_dialogue_sequence_ast)


func _on_fact_store_editor_dialogue_sequence_ast_selected(selected_dialogue_sequence_ast: ParleyDialogueSequenceAst) -> void:
	dialogue_sequence_ast_selected.emit(selected_dialogue_sequence_ast)


func _on_action_store_editor_dialogue_sequence_ast_changed(new_dialogue_sequence_ast: ParleyDialogueSequenceAst) -> void:
	dialogue_sequence_ast_changed.emit(new_dialogue_sequence_ast)


func _on_action_store_editor_dialogue_sequence_ast_selected(new_dialogue_sequence_ast: ParleyDialogueSequenceAst) -> void:
	dialogue_sequence_ast_selected.emit(new_dialogue_sequence_ast)


func _on_character_store_editor_dialogue_sequence_ast_changed(new_dialogue_sequence_ast: ParleyDialogueSequenceAst) -> void:
	dialogue_sequence_ast_changed.emit(new_dialogue_sequence_ast)


func _on_character_store_editor_dialogue_sequence_ast_selected(new_dialogue_sequence_ast: ParleyDialogueSequenceAst) -> void:
	dialogue_sequence_ast_selected.emit(new_dialogue_sequence_ast)
#endregion
