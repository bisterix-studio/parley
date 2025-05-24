@tool
# TODO: prefix with Parley
class_name ActionNodeEditor extends NodeEditor


var action_store: ActionStore
@export var description: String = "": set = _on_description_changed
@export var action_type: ActionNodeAst.ActionType = ActionNodeAst.ActionType.SCRIPT: set = _on_action_changed
@export var action_script_ref: String = "": set = _set_action_script_ref
@export var values: Array = []: set = _on_values_changed


@onready var description_editor: TextEdit = %DescriptionEditor
@onready var action_type_editor: OptionButton = %ActionTypeEditor
@onready var action_script_selector: OptionButton = %ActionScriptSelector
@onready var values_editor: TextEdit = %ActionValueDescription

signal action_node_changed(id: String, description: String, action: ActionNodeAst.ActionType, action_script_ref: String, values: Array)

func _ready() -> void:
	set_title()
	_render_description()
	_render_action_options()
	_render_values()
	_select_action_type()

func _render_action_options() -> void:
	action_script_selector.clear()
	for action: Action in action_store.actions:
		action_script_selector.add_item(action.name)
	_select_action_script()

# TODO: render to show the weirdness
# Current thought is to define an update function. However,
# should we be doing this across the board now? hmmmm
func _on_description_changed(new_description: String) -> void:
	description = new_description
	_render_description()

func _render_description() -> void:
	if description_editor and description_editor.text != description:
		description_editor.text = description

func _on_action_changed(new_action_type: ActionNodeAst.ActionType) -> void:
	action_type = new_action_type
	_select_action_type()

func _set_action_script_ref(new_action_script_ref: String) -> void:
	action_script_ref = new_action_script_ref
	_select_action_script()

func _on_values_changed(new_values: Array) -> void:
	values = new_values
	_render_values()

func _render_values() -> void:
	if values_editor and values.size() > 0:
		# TODO: support multiple values
		values_editor.text = values[0]

func _select_action_type() -> void:
	if action_type_editor:
		var selected_index: int = -1
		var count: int = 0
		for action_type_def: ActionNodeAst.ActionType in ActionNodeAst.ActionType.values():
			if action_type == action_type_def:
				selected_index = count
			count += 1
		if action_type_editor.selected != selected_index:
			action_type_editor.select(selected_index)

func _select_action_script() -> void:
	if action_script_selector:
		var selected_index: int = action_store.get_action_index_by_ref(action_script_ref)
		if action_script_selector.selected != selected_index:
			action_script_selector.select(selected_index)

#region SIGNALS
func _on_action_description_text_changed() -> void:
	description = description_editor.text
	_emit_action_node_changed()

func _on_action_type_option_item_selected(index: int) -> void:
	var action_text: String = action_type_editor.get_item_text(index)
	action_type = ActionNodeAst.get_action_type(action_text)
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
	var action: Action = action_store.actions[index]
	action_script_ref = action.ref.resource_path
	_emit_action_node_changed()

func _emit_action_node_changed() -> void:
	action_node_changed.emit(id, description, action_type, action_script_ref, values)
#endregion
