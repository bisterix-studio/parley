@tool
# TODO: prefix with Parley
class_name ConditionNode extends ParleyGraphNode


@export var description: String = ""
@onready var description_container: Label = %ConditionDescription


const condition_scene: PackedScene = preload('./condition.tscn')

#############
# Lifecycle #
#############
func _ready() -> void:
	setup(DialogueAst.Type.CONDITION)
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
func select_from_slot(from_slot: int) -> void:
	var slot: int
	match from_slot:
		0:
			slot = 1
		1:
			slot = 2
		_:
			ParleyUtils.log.info("Unknown from slot: %s" % [from_slot])
			return
	set_slot_color_right(slot, Color.CORNFLOWER_BLUE)


## Unselect from slot by returning back to original colour
func unselect_from_slot(from_slot: int) -> void:
	var slot: int
	var colour: Color
	match from_slot:
		0:
			slot = 1
			colour = Color.CHARTREUSE
		1:
			slot = 2
			colour = Color.FIREBRICK
		_:
			ParleyUtils.log.info("Unknown from slot: %s" % [from_slot])
			return
	set_slot_color_right(slot, colour)
