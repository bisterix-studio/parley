# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

@tool
class_name ParleyJumpNodeEditor extends ParleyBaseNodeEditor


#region DEFS
const ParleyConstants = preload('../../constants.gd')


@export var dialogue_sequence_ast_ref: String = "": set = _set_dialogue_sequence_ast_ref


@onready var dialogue_sequence_ast_editor: ParleyResourceEditor = %DialogueSequenceAstEditor


signal jump_node_changed(id: String, dialogue_sequence_ast_ref: String)
signal dialogue_sequence_ast_selected(selected_dialogue_sequence_ast: ParleyDialogueSequenceAst)
#endregion


#region LIFECYCLE
func _ready() -> void:
	set_title()
	_render_dialogue_sequence_ast_editor()
#endregion


#region SETTERS
# TODO: can we get a list of all DS's registered in Parley
func _set_dialogue_sequence_ast_ref(new_dialogue_sequence_ast_ref: String) -> void:
	dialogue_sequence_ast_ref = new_dialogue_sequence_ast_ref
	_render_dialogue_sequence_ast_editor()
#endregion


#region RENDERERS
func _render_dialogue_sequence_ast_editor() -> void:
	if dialogue_sequence_ast_editor:
		dialogue_sequence_ast_editor.resource = load(dialogue_sequence_ast_ref) if ResourceLoader.exists(dialogue_sequence_ast_ref) else null
#endregion


#region SIGNALS
func _on_dialogue_sequence_ast_editor_resource_changed(resource: Resource) -> void:
	if resource and resource.resource_path and resource is ParleyDialogueSequenceAst:
		dialogue_sequence_ast_ref = ParleyUtils.resource.get_uid(resource)
		_emit_jump_node_changed()


func _emit_jump_node_changed() -> void:
	jump_node_changed.emit(id, dialogue_sequence_ast_ref)


func _on_edit_dialogue_sequence_button_pressed() -> void:
	if not dialogue_sequence_ast_ref or not ResourceLoader.exists(dialogue_sequence_ast_ref):
		return
	var dialogue_sequence_ast: ParleyDialogueSequenceAst = load(dialogue_sequence_ast_ref)
	if dialogue_sequence_ast is ParleyDialogueSequenceAst:
		if Engine.is_editor_hint():
			EditorInterface.set_main_screen_editor("Parley")
		dialogue_sequence_ast_selected.emit(dialogue_sequence_ast_editor.resource)
#endregion
