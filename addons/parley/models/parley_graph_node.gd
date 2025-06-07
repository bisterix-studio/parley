# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

@tool
class_name ParleyGraphNode extends GraphNode


var id: String = ""
var type: ParleyDialogueSequenceAst.Type = ParleyDialogueSequenceAst.Type.UNKNOWN
const slot_icon: Texture2D = preload("../assets/ArrowHead.svg")


func _ready() -> void:
	setup(type)

func setup(new_type: ParleyDialogueSequenceAst.Type, title_override: Variant = null, colour_override: Variant = null) -> void:
	type = new_type
	set_titlebar(title_override, colour_override)
	set_base_panel()
	custom_minimum_size = Vector2(350, 350)
	z_index = 10


## Set slot style
## Example: set_slot_style(0)
func set_slot_style(idx: int) -> void:
	set_slot_custom_icon_left(idx, slot_icon)


## Sets the title bar for the Graph Node.
## If overrides are defined for title and colour,
## they will be used.
## Example: node.set_titlebar()
func set_titlebar(title_override: Variant = null, colour_override: Variant = null) -> void:
	title = "%s [ID: %s]" % [title_override if title_override else ParleyDialogueSequenceAst.get_type_name(type), id.replace(ParleyNodeAst.id_prefix, '')]
	var titlebar: StyleBoxFlat = get_theme_stylebox("titlebar").duplicate()
	titlebar.bg_color = colour_override if colour_override is Color else ParleyDialogueSequenceAst.get_type_colour(type)
	titlebar.corner_detail = 5
	titlebar.corner_radius_top_left = 3
	titlebar.corner_radius_top_right = 3
	titlebar.corner_radius_bottom_left = 0
	titlebar.corner_radius_bottom_right = 0
	titlebar.content_margin_left = 15
	titlebar.content_margin_right = 15
	titlebar.content_margin_top = 5
	titlebar.content_margin_bottom = 5
	add_theme_stylebox_override("titlebar", titlebar)


## Sets the base panel for the Graph Node.
## Example: node.set_base_panel()
func set_base_panel() -> void:
	var panel: StyleBoxFlat = get_theme_stylebox("panel").duplicate()
	panel.corner_detail = 5
	panel.corner_radius_top_left = 0
	panel.corner_radius_top_right = 0
	panel.corner_radius_bottom_left = 3
	panel.corner_radius_bottom_right = 3
	panel.content_margin_left = 3
	panel.content_margin_right = 3
	panel.content_margin_top = 5
	panel.content_margin_bottom = 5
	add_theme_stylebox_override("panel", panel)


## Select from slot by changing to blue colour
func select_from_slot(from_slot: int, colour: Color = Color.CORNFLOWER_BLUE) -> void:
	set_slot_color_right(from_slot, colour)


## Select to slot by changing to blue colour
func select_to_slot(to_slot: int, colour: Color = Color.CORNFLOWER_BLUE) -> void:
	set_slot_color_left(to_slot, colour)


# TODO: rename
## Deselect from slot by returning back to original colour
func deselect_from_slot(from_slot: int, colour: Color = Color.CHARTREUSE) -> void:
	set_slot_color_right(from_slot, colour)


# TODO: rename
## Deselect to slot by returning back to original colour
func unselect_to_slot(to_slot: int, colour: Color = Color.CHARTREUSE) -> void:
	set_slot_color_left(to_slot, colour)


## Get the Node to slot colour.
func get_to_slot_colour(to_slot: int) -> Color:
	return get_slot_color_left(to_slot)


## Get the Node from slot colour.
func get_from_slot_colour(from_slot: int) -> Color:
	return get_slot_color_right(from_slot)
