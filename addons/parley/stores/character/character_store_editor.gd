# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

@tool
class_name ParleyCharacterStoreEditor extends PanelContainer


#region DEFS
const CharacterEditor: PackedScene = preload("../../components/character/character_editor.tscn")


var parley_manager: ParleyManager
var character_store: ParleyCharacterStore = ParleyCharacterStore.new(): set = _set_character_store
var dialogue_sequence_ast: ParleyDialogueSequenceAst: set = _set_dialogue_sequence_ast
var character_filter: String = "": set = _set_character_filter
var characters: Array[ParleyCharacter] = []: set = _set_characters
var filtered_characters: Array[ParleyCharacter] = []


@onready var characters_container: VBoxContainer = %CharactersContainer
@onready var character_store_editor: ParleyResourceEditor = %CharacterStore
@onready var dialogue_sequence_container: ParleyResourceEditor = %DialogueSequenceContainer
@onready var add_character_button: Button = %AddCharacterButton
@onready var save_character_store_button: Button = %SaveCharacterStoreButton
@onready var invalid_character_store_button: Button = %InvalidCharacterStoreButton
@onready var new_character_store_button: Button = %NewCharacterStoreButton
@onready var register_character_store_modal: ParleyRegisterStoreModal = %RegisterCharacterStoreModal


signal dialogue_sequence_ast_selected(dialogue_sequence_ast: ParleyDialogueSequenceAst)
signal dialogue_sequence_ast_changed(dialogue_sequence_ast: ParleyDialogueSequenceAst)
signal character_store_changed(character_store: ParleyCharacterStore)
#endregion


#region LIFECYCLE
func _ready() -> void:
	character_store_editor.resource = character_store
	characters = character_store.characters
	_render()


func _clear_characters() -> void:
	for child: Node in characters_container.get_children():
		child.queue_free()
#endregion


#region SETTERS
func _set_dialogue_sequence_ast(new_dialogue_sequence_ast: ParleyDialogueSequenceAst) -> void:
	if dialogue_sequence_ast != new_dialogue_sequence_ast:
		dialogue_sequence_ast = new_dialogue_sequence_ast
		_reload_dialogue_sequence_ast()


func _reload_dialogue_sequence_ast() -> void:
	_render_dialogue_sequence()


func _set_character_store(new_character_store: ParleyCharacterStore) -> void:
	if character_store != new_character_store:
		character_store = new_character_store
		if character_store_editor.resource != character_store:
			character_store_editor.resource = character_store
		if character_store:
			characters = character_store.characters
		else:
			characters = []
		character_store_changed.emit(character_store)
	_render_save_character_store_button()
	_render_invalid_character_store_button()

func _set_characters(new_characters: Array[ParleyCharacter]) -> void:
	characters = new_characters
	filtered_characters = []
	for character: ParleyCharacter in characters:
		var raw_character_string: String = str(inst_to_dict(character))
		if not character_filter or raw_character_string.containsn(character_filter):
			filtered_characters.append(character)
	_render_characters()
	if character_store:
		character_store.emit_changed()


func _set_character_filter(new_character_filter: String) -> void:
	character_filter = new_character_filter
	_set_characters(characters)
#endregion


#region RENDERERS
func _render() -> void:
	_render_character_store_editor()
	_render_dialogue_sequence()
	_render_add_character_button()
	_render_new_character_store_button()
	_render_save_character_store_button()
	_render_invalid_character_store_button()
	_render_characters()

func _render_dialogue_sequence() -> void:
	if dialogue_sequence_container and dialogue_sequence_ast and dialogue_sequence_ast.resource_path:
		dialogue_sequence_container.base_type = ParleyDialogueSequenceAst.type_name
		dialogue_sequence_container.resource = dialogue_sequence_ast


func _render_add_character_button() -> void:
	if add_character_button:
		add_character_button.tooltip_text = "Add Character to the currently selected store."


func _render_character_store_editor() -> void:
	if character_store_editor and (not character_store or not character_store.resource_path):
		character_store_editor.resource = null


func _render_save_character_store_button() -> void:
	if save_character_store_button:
		save_character_store_button.tooltip_text = "Save Character Store."
		if not character_store or not character_store.resource_path:
			save_character_store_button.hide()
		else:
			save_character_store_button.show()


func _render_invalid_character_store_button() -> void:
	if invalid_character_store_button:
		invalid_character_store_button.tooltip_text = "Invalid Character Store because it does not contain a resource path, please rectify or create and register a new Character Store."
		if character_store and character_store.resource_path:
			invalid_character_store_button.hide()
		else:
			invalid_character_store_button.show()


func _render_new_character_store_button() -> void:
	if new_character_store_button:
		new_character_store_button.tooltip_text = "Create and register new Character Store."


func _render_characters() -> void:
	if characters_container:
		_clear_characters()
		var index: int = 0
		for character: ParleyCharacter in filtered_characters:
			var character_editor: ParleyCharacterEditor = CharacterEditor.instantiate()
			character_editor.character_id = character.id
			character_editor.character_name = character.name
			ParleyUtils.signals.safe_connect(character_editor.character_changed, _on_character_changed.bind(character))
			ParleyUtils.signals.safe_connect(character_editor.character_removed, _on_character_removed.bind(character))
			characters_container.add_child(character_editor)
			if index != filtered_characters.size() - 1:
				var horizontal_separator: HSeparator = HSeparator.new()
				characters_container.add_child(horizontal_separator)
			index += 1
#endregion


#region SIGNALS
func _on_character_changed(new_id: String, new_name: String, character: ParleyCharacter) -> void:
	character.id = new_id
	character.name = new_name
	if character_store:
		character_store.emit_changed()


func _on_character_removed(character_id: String, _character: ParleyCharacter) -> void:
	character_store.remove_character(character_id)
	characters = character_store.characters


func _on_add_character_button_pressed() -> void:
	var _new_character: ParleyCharacter = character_store.add_character()
	characters = character_store.characters


func _on_filter_characters_text_changed(new_character_filter: String) -> void:
	character_filter = new_character_filter


func _on_save_character_store_button_pressed() -> void:
	_save()


func _on_new_character_store_button_pressed() -> void:
	register_character_store_modal.show()
	register_character_store_modal.clear()
	register_character_store_modal.file_mode = FileDialog.FileMode.FILE_MODE_SAVE_FILE
	register_character_store_modal.resource_editor.resource = ParleyCharacterStore.new()
	# TODO: get from config
	register_character_store_modal.path_edit.text = "res://characters/new_character_store.tres"
	register_character_store_modal.id_valid = true
	register_character_store_modal.script_valid = true
	register_character_store_modal.resource_exists = true


func _on_dialogue_sequence_container_resource_changed(new_dialogue_sequence_ast: Resource) -> void:
	if new_dialogue_sequence_ast is ParleyDialogueSequenceAst:
		dialogue_sequence_ast = new_dialogue_sequence_ast
		dialogue_sequence_ast_changed.emit(dialogue_sequence_ast)


func _on_dialogue_sequence_container_resource_selected(selected_dialogue_sequence_ast: Resource, _inspect: bool) -> void:
	if dialogue_sequence_ast is ParleyDialogueSequenceAst:
		dialogue_sequence_ast_selected.emit(selected_dialogue_sequence_ast)


func _on_register_character_store_modal_store_registered(store: ParleyStore) -> void:
	_register_character_store(store, true)


func _on_character_store_resource_changed(store: Resource) -> void:
	if store is ParleyCharacterStore:
		_register_character_store(store as ParleyCharacterStore, true)
	else:
		character_store = null
#endregion


#region ACTIONS
func _register_character_store(store: ParleyStore, new: bool) -> void:
	if store is ParleyCharacterStore:
		character_store = store
		if new and parley_manager:
			parley_manager.register_character_store(character_store)
		_render()


func _save() -> void:
	var result: int = ResourceSaver.save(character_store)
	if result != OK:
		push_error(ParleyUtils.log.error_msg("Error saving character store [ID: %s]. Code: %d" % [character_store.id, result]))
		return
#endregion
