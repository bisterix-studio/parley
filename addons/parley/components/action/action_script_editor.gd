# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

@tool
class_name ParleyActionScriptEditor extends PanelContainer


#region DEFS
const StringEditor: PackedScene = preload("../editor/string_editor.tscn")


@export var action_id: String = ""
@export var action_name: String = ""
@export var action_ref: Resource: set = _on_set_action_ref


@onready var _id_editor: ParleyStringEditor = %IdEditor
@onready var _name_editor: ParleyStringEditor = %NameEditor
@onready var _resource_editor: ParleyResourceEditor = %ResourceEditor


signal action_changed(id: String, name: String, action_ref: String)
signal action_removed(id: String)
#endregion


#region LIFECYCLE
func _ready() -> void:
	_render()
#endregion


#region SETTERS
func _on_set_action_ref(new_action_ref: Resource) -> void:
	action_ref = new_action_ref
	_render_action_ref()
#endregion


#region RENDERERS
func _render() -> void:
	_render_id_editor()
	_render_name_editor()
	_render_action_ref()


func _render_id_editor() -> void:
	if _id_editor:
		_id_editor.value = action_id


func _render_name_editor() -> void:
	if _name_editor:
		_name_editor.value = action_name


func _render_action_ref() -> void:
	if _resource_editor and action_ref:
		_resource_editor.resource = action_ref


func _clear() -> void:
	for child: Node in get_children():
		child.queue_free()
#endregion


#region SIGNALS
func _on_id_editor_value_changed(new_id: String) -> void:
	action_id = new_id
	_emit_action_changed()


func _on_name_editor_value_changed(new_name: String) -> void:
	action_name = new_name
	_emit_action_changed()


func _on_resource_editor_resource_changed(resource: Resource) -> void:
	action_ref = resource
	_emit_action_changed()


func _on_resource_editor_resource_selected(_resource: Resource, _inspect: bool) -> void:
	if _resource is Script:
		var resource: Script = _resource
		EditorInterface.edit_script(resource)
		EditorInterface.set_main_screen_editor('Script')


func _on_delete_button_pressed() -> void:
	action_removed.emit(action_id)


func _emit_action_changed() -> void:
	action_changed.emit(action_id, action_name, action_ref)
#endregion
