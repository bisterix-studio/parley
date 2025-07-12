# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

@tool
class_name ParleyJumpNode extends ParleyGraphNode


#region DEFS
@export var dialogue_sequence_ast: ParleyDialogueSequenceAst = ParleyDialogueSequenceAst.new(): set = _on_set_dialogue_sequence_ast


@onready var dialogue_sequence_title_label: Label = %DialogueSequenceTitle
@onready var dialogue_sequence_resource_editor: ParleyResourceEditor = %DialogueSequenceAstEditor
#endregion


#region LIFECYCLE
func _ready() -> void:
	setup(ParleyDialogueSequenceAst.Type.JUMP)
	set_slot(0, true, 0, Color.CHARTREUSE, false, 0, Color.CHARTREUSE)
	set_slot_style(0)
	_render_dialogue_sequence()
	_render_dialogue_sequence_resource()
#endregion


#region SETTERS
func _on_set_dialogue_sequence_ast(new_dialogue_sequence_ast: ParleyDialogueSequenceAst) -> void:
	# TODO: don't use a label, instead use a resource editor but upon selection jump to the Dialogue Sequence
	dialogue_sequence_ast = new_dialogue_sequence_ast
	_render_dialogue_sequence()
	_render_dialogue_sequence_resource()
#endregion


#region RENDERERS
func _render_dialogue_sequence() -> void:
	if dialogue_sequence_title_label:
		dialogue_sequence_title_label.text = dialogue_sequence_ast.title if dialogue_sequence_ast.title else "Unknown"


func _render_dialogue_sequence_resource() -> void:
	if dialogue_sequence_resource_editor:
		dialogue_sequence_resource_editor.resource = dialogue_sequence_ast
#endregion
