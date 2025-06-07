# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

@tool
class_name ParleyGroupNodeEditor extends ParleyBaseNodeEditor

signal group_node_changed(id: String, name: String, colour: Color)

@export var group_name: String = "": set = _on_group_name_changed

@export var colour: Color = ParleyDialogueSequenceAst.get_type_colour(ParleyDialogueSequenceAst.Type.UNKNOWN): set = _on_colour_changed

@onready var group_name_editor: LineEdit = %GroupNodeName
@onready var colour_picker_button: ColorPickerButton = %GroupNodeColorPickerButton

func _ready() -> void:
	_render_group_name()
	_render_colour()

func _on_group_name_changed(new_group_name: String) -> void:
	group_name = new_group_name
	_render_group_name()

func _render_group_name() -> void:
	set_title(group_name)
	if group_name_editor and group_name_editor.text != group_name:
		group_name_editor.text = group_name

func _on_colour_changed(new_colour: Color) -> void:
	colour = new_colour
	_render_colour()

func _render_colour() -> void:
	if colour_picker_button and colour_picker_button.color != colour:
		colour_picker_button.color = colour

#region SIGNALS
func _on_group_node_color_picker_button_color_changed(new_color: Color) -> void:
	colour = new_color
	_emit_group_node_changed()

func _on_group_node_name_text_changed(new_group_name: String) -> void:
	group_name = new_group_name
	_emit_group_node_changed()

func _emit_group_node_changed() -> void:
	group_node_changed.emit(id, group_name, colour)
#endregion
