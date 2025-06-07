# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

@tool
class_name ParleyGroupNode extends ParleyGraphNode

## The name associated with the Group Node AST
var group_name: String = "": set = _on_group_name_changed


## The node IDs associated with the Group Node AST
var node_ids: Array = []


## The colour associated with the Group Node AST
var colour: Color = ParleyDialogueSequenceAst.get_type_colour(ParleyDialogueSequenceAst.Type.GROUP).lightened(0.5): set = _on_colour_changed


#############
# Lifecycle #
#############
func _ready() -> void:
	setup(ParleyDialogueSequenceAst.Type.GROUP, group_name)
	z_index = 0
	custom_minimum_size = Vector2(350, 350)
	clear_all_slots()

	colour = Color(colour.r, colour.g, colour.b, colour.a * 0.3 if colour.a == 1 else colour.a)
	_set_theme()


func _on_group_name_changed(new_group_name: String) -> void:
	group_name = new_group_name
	set_titlebar(group_name)


func _on_colour_changed(new_colour: Color) -> void:
	colour = Color(new_colour.r, new_colour.g, new_colour.b, new_colour.a * 0.3 if new_colour.a == 1 else new_colour.a)
	_set_theme()

func _set_theme() -> void:
	# Panel
	var panel: StyleBoxFlat = get_theme_stylebox("panel").duplicate()
	panel.bg_color = colour
	add_theme_stylebox_override("panel", panel)
	
	# Panel Selected
	var panel_selected: StyleBoxFlat = get_theme_stylebox("panel_selected").duplicate()
	panel_selected.bg_color = colour
	panel_selected.border_color = Color('#ffffff')
	panel_selected.border_width_left = 4
	panel_selected.border_width_right = 4
	panel_selected.border_width_bottom = 4
	panel_selected.corner_radius_top_left = 0
	panel_selected.corner_radius_top_right = 0
	add_theme_stylebox_override("panel_selected", panel_selected)

	# Title bar Selected
	var titlebar_selected: StyleBoxFlat = get_theme_stylebox("titlebar_selected").duplicate()
	titlebar_selected.border_color = Color('#ffffff')
	titlebar_selected.border_width_left = 4
	titlebar_selected.border_width_right = 4
	titlebar_selected.border_width_top = 4
	titlebar_selected.corner_radius_bottom_left = 0
	titlebar_selected.corner_radius_bottom_right = 0
	add_theme_stylebox_override("titlebar_selected", titlebar_selected)
