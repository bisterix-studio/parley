# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

@tool
class_name ParleyDialogueNodeEditor extends ParleyBaseNodeEditor


#region DEFS
var character_store: ParleyCharacterStore: set = _set_character_store
@export var character: String = "": set = _set_character
@export var dialogue: String = "": set = _set_dialogue


@onready var character_selector: OptionButton = %CharacterSelector
@onready var dialogue_editor: TextEdit = %DialogueEditor


signal dialogue_node_changed(id: String, character: String, dialogue: String)
#endregion


#region LIFECYCLE
func _ready() -> void:
	set_title()
	_render_dialogue()
	_render_character_options()
	if character_store:
		ParleyUtils.signals.safe_connect(character_store.changed, _on_character_store_changed)
#endregion


#region SETTERS
func _set_character_store(new_character_store: ParleyCharacterStore) -> void:
	character_store = new_character_store
	if character_store != new_character_store:
		if character_store:
			ParleyUtils.signals.safe_disconnect(character_store.changed, _on_character_store_changed)
		character_store = new_character_store
		if character_store:
			ParleyUtils.signals.safe_connect(character_store.changed, _on_character_store_changed)
	_render_character_options()


func _set_dialogue(new_dialogue: String) -> void:
	dialogue = new_dialogue
	_render_dialogue()


func _set_character(new_character: String) -> void:
	character = new_character
	_render_character()
#endregion


#region RENDERERS
func _render_dialogue() -> void:
	if dialogue_editor and dialogue_editor.text != dialogue:
		dialogue_editor.text = dialogue


func _render_character_options() -> void:
	if not character_selector:
		return
	character_selector.clear()
	if not character_store:
		return
	for store_character: ParleyCharacter in character_store.characters:
		character_selector.add_item(store_character.name)
	_render_character()


func _render_character() -> void:
	if character_store and character_selector:
		var selected_index: int = character_store.get_character_index_by_ref(character)
		if character_selector.selected != selected_index and selected_index < character_selector.item_count:
			character_selector.select(selected_index)
#endregion


#region SIGNALS
func _on_dialogue_editor_text_changed() -> void:
	dialogue = dialogue_editor.text
	_emit_dialogue_node_changed()


func _on_character_selector_item_selected(index: int) -> void:
	var new_character: String = character_store.get_ref_by_index(index)
	if new_character != "":
		character = new_character
		_emit_dialogue_node_changed()


func _on_character_store_changed() -> void:
	_render_character_options()


func _emit_dialogue_node_changed() -> void:
	dialogue_node_changed.emit(id, character, dialogue)
#endregion
