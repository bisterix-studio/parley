@tool
# TODO: prefix with Parley
class_name ActionNode extends ParleyGraphNode

@export var description: String = "": set = _on_description_changed
@export var action_type: ActionNodeAst.ActionType = ActionNodeAst.ActionType.SCRIPT: set = _on_action_type_changed
@export var action_script_name: String = "": set = _on_action_script_name_changed
@export var values: Array = []: set = _on_values_changed

@export var description_editor: Label
@export var action_type_editor: Label
@export var action_script_name_editor: Label
@export var values_editor: Label

#############
# Lifecycle #
#############
func _ready() -> void:
	setup(DialogueAst.Type.ACTION)
	clear_all_slots()
	set_slot(0, true, 0, Color.CHARTREUSE, true, 0, Color.CHARTREUSE)
	set_slot_style(0)


func _on_description_changed(new_description: String) -> void:
	description = new_description
	if description_editor:
		description_editor.text = description


func _on_action_type_changed(new_action_type: ActionNodeAst.ActionType) -> void:
	action_type = new_action_type
	if action_type_editor:
		action_type_editor.text = ActionNodeAst.get_action_type_name(action_type)


func _on_action_script_name_changed(new_action_script_name: String) -> void:
	action_script_name = new_action_script_name
	if action_script_name_editor:
		action_script_name_editor.text = action_script_name


func _on_values_changed(new_values: Array) -> void:
	values = new_values
	if values_editor and values.size() > 0:
		# TODO: support multiple values
		values_editor.text = values[0]
