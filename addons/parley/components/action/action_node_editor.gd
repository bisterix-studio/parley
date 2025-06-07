# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

@tool
class_name ParleyActionNodeEditor extends ParleyBaseNodeEditor


#region DEFS
var action_store: ParleyActionStore: set = _set_action_store
@export var description: String = "": set = _set_description
@export var action_type: ParleyActionNodeAst.ActionType = ParleyActionNodeAst.ActionType.SCRIPT: set = _set_action_type
@export var action_script_ref: String = "": set = _set_action_script_ref
@export var values: Array = []: set = _set_values


@onready var description_editor: TextEdit = %DescriptionEditor
@onready var action_type_editor: OptionButton = %ActionTypeEditor
@onready var action_script_selector: OptionButton = %ActionScriptSelector
@onready var values_editor: TextEdit = %ActionValueDescription


signal action_node_changed(id: String, description: String, action: ParleyActionNodeAst.ActionType, action_script_ref: String, values: Array)
#endregion


#region LIFECYCLE
func _ready() -> void:
	set_title()
	_render()
	if action_store:
		ParleyUtils.signals.safe_connect(action_store.changed, _on_action_store_changed)
#endregion


#region SETTERS
func _set_action_store(new_action_store: ParleyActionStore) -> void:
	if action_store != new_action_store:
		if action_store:
			ParleyUtils.signals.safe_disconnect(action_store.changed, _on_action_store_changed)
		action_store = new_action_store
		if action_store:
			ParleyUtils.signals.safe_connect(action_store.changed, _on_action_store_changed)
		_render()


func _set_description(new_description: String) -> void:
	description = new_description
	_render_description()


func _set_action_type(new_action_type: ParleyActionNodeAst.ActionType) -> void:
	action_type = new_action_type
	_select_action_type()


func _set_action_script_ref(new_action_script_ref: String) -> void:
	action_script_ref = new_action_script_ref
	_select_action_script()


func _set_values(new_values: Array) -> void:
	values = new_values
	_render_values()
#endregion


#region RENDERERS
func _render() -> void:
	_render_description()
	_render_action_options()
	_render_values()
	_select_action_type()


func _render_action_options() -> void:
	if action_script_selector:
		action_script_selector.clear()
		if action_store:
			for action: ParleyAction in action_store.actions:
				action_script_selector.add_item(action.name)
		_select_action_script()


func _render_description() -> void:
	if description_editor and description_editor.text != description:
		description_editor.text = description


func _render_values() -> void:
	if values_editor and values.size() > 0:
		# TODO: support multiple values
		values_editor.text = values[0]


func _select_action_type() -> void:
	if action_type_editor:
		var selected_index: int = -1
		var count: int = 0
		for action_type_def: ParleyActionNodeAst.ActionType in ParleyActionNodeAst.ActionType.values():
			if action_type == action_type_def:
				selected_index = count
			count += 1
		if action_type_editor.selected != selected_index:
			action_type_editor.select(selected_index)


func _select_action_script() -> void:
	if action_script_selector:
		var selected_index: int = -1
		if action_store:
			selected_index = action_store.get_action_index_by_ref(action_script_ref)
		if action_script_selector.selected != selected_index:
			action_script_selector.select(selected_index)
#endregion


#region SIGNALS
func _on_action_store_changed() -> void:
	_render()


func _on_action_description_text_changed() -> void:
	description = description_editor.text
	_emit_action_node_changed()


func _on_action_type_option_item_selected(index: int) -> void:
	var action_text: String = action_type_editor.get_item_text(index)
	action_type = ParleyActionNodeAst.get_action_type(action_text)
	_emit_action_node_changed()


func _on_action_value_description_text_changed() -> void:
	if values.size() == 0:
		values.append(values_editor.text)
	else:
		# TODO: support multiple values
		values[0] = values_editor.text
	_emit_action_node_changed()


func _on_action_script_selector_item_selected(index: int) -> void:
	if index == -1 or index >= action_store.actions.size():
		return
	var action: ParleyAction = action_store.actions[index]
	action_script_ref = ParleyUtils.resource.get_uid(action.ref)
	_emit_action_node_changed()


func _on_edit_action_script_button_pressed() -> void:
	if not action_store:
		return
	var action: ParleyAction = action_store.get_action_by_ref(action_script_ref)
	if action.ref is Script:
		var script: Script = action.ref
		EditorInterface.edit_script(script)
		EditorInterface.set_main_screen_editor('Script')


func _emit_action_node_changed() -> void:
	action_node_changed.emit(id, description, action_type, action_script_ref, values)
#endregion
