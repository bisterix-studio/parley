@tool
class_name ParleyEndNode extends ParleyGraphNode

#############
# Lifecycle #
#############
func _ready() -> void:
	setup(ParleyDialogueSequenceAst.Type.END)
	custom_minimum_size = Vector2(200, 100)
	clear_all_slots()
	set_slot(0, true, 0, Color.CHARTREUSE, false, 0, Color.CHARTREUSE)
	set_slot_style(0)
