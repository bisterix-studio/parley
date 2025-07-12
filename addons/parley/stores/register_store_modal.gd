# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

@tool
class_name ParleyRegisterStoreModal extends Window

#region DEFS
@export var type: ParleyStore.Type


var file_mode: FileDialog.FileMode
var id_valid: bool = false: set = _set_id_valid
var script_valid: bool = false: set = _set_script_valid
var resource_exists: bool = false: set = _set_resource_exists
var store_name: String = "Unknown Store"
var default_current_dir: String = ""
var default_current_file: String = ""
var id_value: String = ""


@onready var path_edit: LineEdit = %PathEdit
@onready var choose_path_button: Button = %ChoosePathButton
@onready var choose_path_modal: FileDialog = %ChoosePathModal
@onready var resource_editor: ParleyResourceEditor = %ResourceEditor
@onready var status: RichTextLabel = %Status


signal store_registered(store: ParleyStore)
#endregion


#region LIFECYCLE
func _ready() -> void:
	match type:
		ParleyStore.Type.Character:
			store_name = "Character Store"
			resource_editor.key = store_name
			resource_editor.base_type = "ParleyCharacterStore"
			# TODO: get from config
			default_current_dir = "res://characters"
			default_current_file = "new_character_store.tres"
		ParleyStore.Type.Fact:
			store_name = "Fact Store"
			resource_editor.key = store_name
			resource_editor.base_type = "ParleyFactStore"
			# TODO: get from config
			default_current_dir = "res://facts"
			default_current_file = "new_fact_store.tres"
		ParleyStore.Type.Action:
			store_name = "Action Store"
			resource_editor.key = store_name
			resource_editor.base_type = "ParleyActionStore"
			# TODO: get from config
			default_current_dir = "res://actions"
			default_current_file = "new_action_store.tres"
		_:
			push_warning(ParleyUtils.log.warn_msg("Unknown store type: %s" % [type]))
	clear()


func clear() -> void:
	if path_edit:
		path_edit.text = ""
		path_edit.editable = true
	if resource_editor:
		resource_editor.resource = null
	if choose_path_button:
		choose_path_button.disabled = false
	script_valid = false
	resource_exists = false
#endregion


#region SETTERS
# TODO: ensure uniqueness
func _set_id_valid(_id_valid: bool) -> void:
	id_valid = _id_valid
	_render_status()


func _set_script_valid(_script_valid: bool) -> void:
	script_valid = _script_valid
	_render_status()


func _set_resource_exists(_resource_exists: bool) -> void:
	resource_exists = _resource_exists
	_render_status()
#endregion


#region RENDERERS
func _render_status() -> void:
	if status:
		var id_valid_colour: Color = Color.LIME_GREEN if id_valid else Color.CRIMSON
		var script_valid_colour: Color = Color.LIME_GREEN if script_valid else Color.CRIMSON
		var ready_colour: Color = Color.LIME_GREEN if resource_exists else Color.CRIMSON
		var lines: PackedStringArray = [
			"[color=#%s]" % [id_valid_colour.to_html()],
			"[ul]  ID is valid[/ul][/color][color=#%s]" % [script_valid_colour.to_html()],
			"[ul]  Script/path name is valid[/ul][/color][color=#%s]" % [ready_colour.to_html()],
			"[ul]  Will create or register an %s[/ul][/color]" % [store_name],
		]
		status.text = "\n".join(lines)
#endregion


#region SIGNALS
func _on_id_editor_value_changed(new_value: String) -> void:
	id_value = new_value
	id_valid = true if id_value else false
	if resource_editor:
		if resource_editor.resource is ParleyStore:
			(resource_editor.resource as ParleyStore).id = id_value


func _on_choose_path_modal_file_selected(path: String) -> void:
	path_edit.text = path
	script_valid = true


func _on_choose_path_button_pressed() -> void:
	choose_path_modal.show()
	choose_path_modal.current_dir = default_current_dir
	choose_path_modal.current_file = default_current_file


func _on_cancel_button_pressed() -> void:
	hide()


func _on_resource_editor_resource_changed(resource: ParleyStore) -> void:
	if resource:
		if not id_value:
			if resource.id:
				id_value = resource.id
		else:
			resource.id = id_value
			
		resource_exists = true
		if resource.resource_path:
			script_valid = true
			if path_edit:
				path_edit.text = resource.resource_path
				path_edit.editable = false
			if choose_path_button:
				choose_path_button.disabled = true
		else:
			if path_edit:
				path_edit.editable = true
			if choose_path_button:
				choose_path_button.disabled = false
	else:
		resource_exists = false
		script_valid = false
		if path_edit:
			path_edit.text = ""
			path_edit.editable = true
		if choose_path_button:
			choose_path_button.disabled = false


func _on_register_button_pressed() -> void:
	if resource_editor and resource_editor.resource and path_edit and path_edit.text and id_valid and script_valid and resource_exists:
		var resource: Resource = resource_editor.resource
		var store: ParleyStore
		if resource.resource_path:
			var ok: int = ResourceSaver.save(resource)
			if ok != OK:
				push_error(ParleyUtils.log.error_msg("Error saving %s: %s" % [store_name, ok]))
				return
			store = load(resource.resource_path)
		else:
			var created_store: ParleyStore = await ParleyUtils.file.create_new_resource(
				resource,
				path_edit.text,
				get_tree().create_timer(30).timeout)
			if not created_store:
				push_warning(ParleyUtils.log.warn_msg("Unable to create Store, please check the errors."))
				return
			store = created_store
		store_registered.emit(store)
		hide()
	else:
		push_warning(ParleyUtils.log.warn_msg("Resource not ready to register, please check the errors."))
#endregion
