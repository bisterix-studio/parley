# Copyright 2024-2025 the Bisterix Studio authors. All rights reserved. MIT license.

@tool
class_name ParleyMatchNode extends ParleyGraphNode


#region DEFS
const case_label_scene: PackedScene = preload("./case_label.tscn")


@export var description: String = "": set = _set_description
@export var fact_name: String = "": set = _set_fact_name
@export var cases: Array[Variant] = []: set = _set_cases


@onready var description_label: Label = %MatchDescription
@onready var fact_label: Label = %Fact


static var start_slot: int = 3
#endregion


#region LIFECYCLE
func _ready() -> void:
	setup(ParleyDialogueSequenceAst.Type.MATCH)
	clear_all_slots()
	set_slot(0, true, 0, Color.CHARTREUSE, false, 0, Color.CHARTREUSE)
	set_slot(1, false, 0, Color.CHARTREUSE, false, 0, Color.CHARTREUSE)
	set_slot(2, false, 0, Color.CHARTREUSE, false, 0, Color.CHARTREUSE)
	set_slot_style(0)
	_render_description()
	_render_fact_name()
	_render_cases()
#endregion


#region SETTERS
func _set_description(new_description: String) -> void:
	description = new_description
	_render_description()


func _set_fact_name(new_fact_name: String) -> void:
	fact_name = new_fact_name
	_render_fact_name()
#endregion


#region RENDERERS
# TODO: we may have rendering issues with the edges are lost upon
# slot changes. For now, let's just re-render the slots and then handler
# at a later date.
func _render_cases() -> void:
	if is_node_ready():
		var index: int = 0
		var children: Array = []
		for child: Node in get_children():
			if index >= start_slot:
				remove_child(child)
				child.queue_free()
			index += 1
		for child: Node in children:
			await child.tree_exited
		index = start_slot
		for case: Variant in cases:
			var case_label: ParleyCaseLabel = case_label_scene.instantiate()
			case_label.case = str(case).capitalize()
			add_child(case_label)
			set_slot(index, false, 0, Color.CHARTREUSE, true, 0, Color.CHARTREUSE)
			set_slot_style(index)
			index += 1
		_render_footer(index)
		_refresh_slot_positions()


func _render_footer(index: int) -> void:
	var footer: MarginContainer = MarginContainer.new()
	footer.custom_minimum_size = Vector2(0, 15)
	add_child(footer)
	set_slot(index, false, 0, Color.CHARTREUSE, false, 0, Color.CHARTREUSE)


# Get around what appears to be a bug where the slots are not correctly positioned
# by moving a node back and forth to the original position
func _refresh_slot_positions() -> void:
	position.x += 1
	await get_tree().create_timer(0.01).timeout
	position.x -= 1


func _render_description() -> void:
	if description_label:
		description_label.text = description


func _render_fact_name() -> void:
	if fact_label:
		fact_label.text = fact_name
#endregion


#region SIGNALS
func _set_cases(new_cases: Array[Variant]) -> void:
	cases = new_cases
	_render_cases()
#endregion


#region OVERRIDES
## Select from slot by changing to blue colour
func select_from_slot(from_slot: int, colour: Color = Color.CORNFLOWER_BLUE) -> void:
	set_slot_color_right(from_slot + start_slot, colour)


## Deselect from slot by returning back to original colour
func deselect_from_slot(from_slot: int, colour: Color = Color.CHARTREUSE) -> void:
	set_slot_color_right(from_slot + start_slot, colour)


## Get the Node from slot colour.
func get_from_slot_colour(from_slot: int) -> Color:
	return get_slot_color_right(from_slot + start_slot)
#endregion
