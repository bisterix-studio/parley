# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

@tool
class_name ParleyFactEditor extends PanelContainer

#region DEFS
const StringEditor: PackedScene = preload("../editor/string_editor.tscn")


@export var fact_id: String = ""
@export var fact_name: String = ""
@export var fact_ref: Resource: set = _on_set_fact_ref


@onready var _id_editor: ParleyStringEditor = %IdEditor
@onready var _name_editor: ParleyStringEditor = %NameEditor
@onready var _resource_editor: ParleyResourceEditor = %ResourceEditor


signal fact_changed(id: String, name: String, fact_ref: String)
signal fact_removed(id: String)
#endregion


#region LIFECYCLE
func _ready() -> void:
	_render()
#endregion


#region SETTERS
func _on_set_fact_ref(new_fact_ref: Resource) -> void:
	fact_ref = new_fact_ref
	_render_fact_ref()
#endregion


#region RENDERERS
func _render() -> void:
	_render_id_editor()
	_render_name_editor()
	_render_fact_ref()


func _render_id_editor() -> void:
	if _id_editor:
		_id_editor.value = fact_id


func _render_name_editor() -> void:
	if _name_editor:
		_name_editor.value = fact_name


func _render_fact_ref() -> void:
	if _resource_editor and fact_ref:
		_resource_editor.resource = fact_ref


func _clear() -> void:
	for child: Node in get_children():
		child.queue_free()
#endregion


#region SIGNALS
func _on_id_editor_value_changed(new_id: String) -> void:
	fact_id = new_id
	_emit_fact_changed()


func _on_name_editor_value_changed(new_name: String) -> void:
	fact_name = new_name
	_emit_fact_changed()


func _on_resource_editor_resource_changed(resource: Resource) -> void:
	fact_ref = resource
	_emit_fact_changed()


func _on_resource_editor_resource_selected(_resource: Resource, _inspect: bool) -> void:
	if _resource is Script:
		var resource: Script = _resource
		EditorInterface.edit_script(resource)
		EditorInterface.set_main_screen_editor('Script')


func _on_delete_button_pressed() -> void:
	fact_removed.emit(fact_id)


func _emit_fact_changed() -> void:
	fact_changed.emit(fact_id, fact_name, fact_ref)
#endregion
