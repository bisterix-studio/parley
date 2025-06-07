# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

@tool
class_name ParleyEdgeEditor extends VBoxContainer

@export var edge: ParleyEdgeAst: set = _set_edge

@onready var from_node_value: Label = %FromNodeValue
@onready var from_slot_value: Label = %FromSlotValue
@onready var to_node_value: Label = %ToNodeValue
@onready var to_slot_value: Label = %ToSlotValue
@onready var delete_edge_button: Button = %DeleteEdgeButton
@onready var colour_override_button: ColorPickerButton = %ColorOverrideButton
@onready var colour_override_checkbox: CheckBox = %ColorOverrideCheckBox


signal edge_deleted(edge: ParleyEdgeAst)
signal edge_changed(edge: ParleyEdgeAst)
signal mouse_entered_edge(edge: ParleyEdgeAst)
signal mouse_exited_edge(edge: ParleyEdgeAst)

func _ready() -> void:
	_set_edge(edge)
	apply_theme()
	_render_colour_override_checkbox()
	_render_colour_override_button()


#region SETTERS
func _set_edge(new_edge: ParleyEdgeAst) -> void:
	if new_edge != edge:
		if edge:
			ParleyUtils.signals.safe_disconnect(edge.edge_changed, _on_edge_changed)
		edge = new_edge
		if edge:
			ParleyUtils.signals.safe_connect(edge.edge_changed, _on_edge_changed)
		else:
			_render("", 0, "", 0)
			return
	if edge:
		_render(edge.from_node, edge.from_slot, edge.to_node, edge.to_slot)
#endregion


#region RENDERERS
func _render(from_node: String, from_slot: int, to_node: String, to_slot: int) -> void:
	if from_node_value:
		from_node_value.text = from_node.replace(ParleyNodeAst.id_prefix, '')
	if from_slot_value:
		from_slot_value.text = str(from_slot)
	if to_node_value:
		to_node_value.text = to_node.replace(ParleyNodeAst.id_prefix, '')
	if to_slot_value:
		to_slot_value.text = str(to_slot)


## Applies the edge editor theme
## Example: editor.apply_theme()
func apply_theme() -> void:
	if delete_edge_button:
		delete_edge_button.tooltip_text = "Delete the selected edge."


func _render_colour_override_checkbox() -> void:
	if colour_override_checkbox and edge:
		colour_override_checkbox.button_pressed = edge.should_override_colour


func _render_colour_override_button() -> void:
	if colour_override_button and edge:
		colour_override_button.color = edge.colour_override
		if colour_override_checkbox:
			colour_override_button.disabled = not colour_override_checkbox.button_pressed
#endregion


#region SIGNALS
func _on_delete_edge_button_pressed() -> void:
	edge_deleted.emit(edge)


func _on_mouse_entered() -> void:
	mouse_entered_edge.emit()


func _on_mouse_exited() -> void:
	mouse_exited_edge.emit()


func _on_edge_changed(new_edge: ParleyEdgeAst) -> void:
	edge = new_edge
	edge_changed.emit(new_edge)


func _on_check_box_toggled(should_override_colour: bool) -> void:
	edge.should_override_colour = should_override_colour
	_render_colour_override_button()


func _on_color_override_button_color_changed(new_colour_override: Color) -> void:
	edge.colour_override = new_colour_override
#endregion
