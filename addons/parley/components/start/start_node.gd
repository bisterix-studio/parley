@tool
class_name ParleyStartNode extends ParleyGraphNode

#############
# Lifecycle #
#############
func _ready() -> void:
	setup(ParleyDialogueSequenceAst.Type.START)
	custom_minimum_size = Vector2(200, 100)
	clear_all_slots()
	set_slot(0, false, 0, Color.CHARTREUSE, true, 0, Color.CHARTREUSE)
	set_slot_style(0)
