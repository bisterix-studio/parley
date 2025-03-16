@tool
# TODO: prefix with Parley
class_name DialogueNode extends ParleyGraphNode

@export var character: String = "": set = _on_character_changed
@export var dialogue: String = "": set = _on_dialogue_changed
@export var character_editor: Label
@export var dialogue_editor: Label

#############
# Lifecycle #
#############
func _ready() -> void:
	setup(DialogueAst.Type.DIALOGUE)
	clear_all_slots()
	set_slot(0, true, 0, Color.CHARTREUSE, true, 0, Color.CHARTREUSE)
	set_slot_style(0)


func _on_character_changed(new_character: String) -> void:
	character = new_character
	if character_editor:
		character_editor.text = character


func _on_dialogue_changed(new_dialogue: String) -> void:
	dialogue = new_dialogue
	if dialogue_editor:
		dialogue_editor.text = dialogue
