# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

@tool
class_name ParleyCharacterEditor extends PanelContainer


#region DEFS
const StringEditor: PackedScene = preload("../editor/string_editor.tscn")


@export var character_id: String = ""
@export var character_name: String = ""


@onready var id_editor: ParleyStringEditor = %IdEditor
@onready var name_editor: ParleyStringEditor = %NameEditor


signal character_changed(id: String, name: String)
signal character_removed(id: String)
#endregion


#region LIFECYCLE
func _ready() -> void:
	_render()
#endregion


#region RENDERERS
func _render() -> void:
	_render_id_editor()
	_render_name_editor()


func _render_id_editor() -> void:
	if id_editor:
		id_editor.value = character_id


func _render_name_editor() -> void:
	if name_editor:
		name_editor.value = character_name


func _clear() -> void:
	for child: Node in get_children():
		child.queue_free()
#endregion


#region SIGNALS
func _on_id_editor_value_changed(new_id: String) -> void:
	character_id = new_id
	_emit_character_changed()


func _on_name_editor_value_changed(new_name: String) -> void:
	character_name = new_name
	_emit_character_changed()


func _on_delete_button_pressed() -> void:
	character_removed.emit(character_id)


func _emit_character_changed() -> void:
	character_changed.emit(character_id, character_name)
#endregion
