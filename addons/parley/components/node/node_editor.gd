# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

@tool
class_name ParleyBaseNodeEditor extends VBoxContainer


#region DEFS
var dialogue_sequence_ast: ParleyDialogueSequenceAst = null : set = _set_dialogue_sequence_ast
var node_ast: ParleyNodeAst = null : set = _set_node_ast
@export var id: String = "": set = _set_id
@export var type: ParleyDialogueSequenceAst.Type = ParleyDialogueSequenceAst.Type.UNKNOWN: set = _set_type


@onready var title_label: Label = %TitleLabel
@onready var title_panel: PanelContainer = %TitlePanelContainer


signal delete_node_button_pressed(id: String)
#endregion


#region LIFECYCLE
func _ready() -> void:
	set_title()
#endregion


#region SETTERS
func _set_dialogue_sequence_ast(new_dialogue_sequence_ast: ParleyDialogueSequenceAst) -> void:
	dialogue_sequence_ast = new_dialogue_sequence_ast


func _set_node_ast(new_node_ast: ParleyNodeAst) -> void:
	node_ast = new_node_ast


func _set_id(new_id: String) -> void:
	if id != new_id: id = new_id
	set_title()


func _set_type(new_type: ParleyDialogueSequenceAst.Type) -> void:
	if type != new_type: type = new_type
	set_title()


func set_title(title: String = "", colour: Variant = null) -> void:
	if title_label:
		title_label.text = "%s [ID: %s]" % [title if title else ParleyDialogueSequenceAst.get_type_name(type), id.replace(ParleyNodeAst.id_prefix, '')]
	if title_panel:
		title_panel.get_theme_stylebox('panel').set('bg_color', colour if colour is Color else ParleyDialogueSequenceAst.get_type_colour(type))
#endregion


#region SIGNALS
func _on_delete_node_button_pressed() -> void:
	delete_node_button_pressed.emit(id)
#endregion
