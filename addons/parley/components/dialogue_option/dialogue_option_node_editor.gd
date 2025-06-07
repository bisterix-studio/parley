# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

@tool
class_name ParleyDialogueOptionNodeEditor extends ParleyBaseNodeEditor


#region DEFS
var character_store: ParleyCharacterStore: set = _set_character_store
@export var character: String = "": set = _set_character
@export var option: String = "": set = _set_option


@onready var character_selector: OptionButton = %CharacterSelector
@onready var option_editor: TextEdit = %OptionEditor


signal dialogue_option_node_changed(id: String, character: String, option: String)
#endregion


#region LIFECYCLE
func _ready() -> void:
	set_title()
	_render_option()
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


func _set_option(new_option: String) -> void:
	option = new_option
	_render_option()


func _set_character(new_character: String) -> void:
	character = new_character
	_render_character()
#endregion


#region RENDERERS
func _render_option() -> void:
	if option_editor and option_editor.text != option:
		option_editor.text = option


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
func _on_code_edit_text_changed() -> void:
	option = option_editor.text
	emit_dialogue_option_node_changed()


func _on_character_selector_item_selected(index: int) -> void:
	var new_character: String = character_store.get_ref_by_index(index)
	if new_character != "":
		character = new_character
		emit_dialogue_option_node_changed()


func _on_character_store_changed() -> void:
	_render_character_options()


func emit_dialogue_option_node_changed() -> void:
	dialogue_option_node_changed.emit(id, character, option)
#endregion
