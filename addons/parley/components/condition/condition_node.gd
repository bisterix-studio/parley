# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

@tool
class_name ParleyConditionNode extends ParleyGraphNode


@export var description: String = ""
@onready var description_container: Label = %ConditionDescription


const null_colour: Color = Color(0, 0, 0, 0)


#############
# Lifecycle #
#############
func _ready() -> void:
	setup(ParleyDialogueSequenceAst.Type.CONDITION)
	custom_minimum_size = Vector2(350, 250)
	update(description)
	clear_all_slots()
	set_slot(0, true, 0, Color.CHARTREUSE, false, 0, Color.CHARTREUSE)
	set_slot_style(0)
	set_slot(1, false, 0, Color.CHARTREUSE, true, 0, Color.CHARTREUSE)
	set_slot_style(1)
	set_slot(2, false, 0, Color.CHARTREUSE, true, 0, Color.FIREBRICK)
	set_slot_style(2)


func update(p_description: String) -> void:
	description = p_description
	description_container.text = description


## Select from slot by changing to blue colour
func select_from_slot(from_slot: int, _colour: Color = Color.CHARTREUSE) -> void:
	var slot: int
	match from_slot:
		0:
			slot = 1
		1:
			slot = 2
		_:
			print_rich(ParleyUtils.log.info_msg("Unknown from slot: %s" % [from_slot]))
			return
	set_slot_color_right(slot, Color.CORNFLOWER_BLUE)


## Deselect from slot by returning back to original colour
func deselect_from_slot(from_slot: int, colour: Color = null_colour) -> void:
	var slot: int
	var slot_colour: Color
	match from_slot:
		0:
			slot = 1
			slot_colour = colour if colour != null_colour else Color.CHARTREUSE
		1:
			slot = 2
			slot_colour = colour if colour != null_colour else Color.FIREBRICK
		_:
			print_rich(ParleyUtils.log.info_msg("Unknown from slot: %s" % [from_slot]))
			return
	set_slot_color_right(slot, slot_colour)


## Get the Node from slot colour.
func get_from_slot_colour(from_slot: int) -> Color:
	var slot: int
	match from_slot:
		0:
			slot = 1
		1:
			slot = 2
		_:
			print_rich(ParleyUtils.log.info_msg("Unknown from slot: %s" % [from_slot]))
			return Color.CHARTREUSE
	return get_slot_color_right(slot)
