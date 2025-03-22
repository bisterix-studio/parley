@tool
# TODO: prefix with Parley
class_name DialogueNode extends ParleyGraphNode

@export var character: String = "": set = _on_set_character
@export var dialogue: String = "": set = _on_set_dialogue
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


func _on_set_character(new_character: String) -> void:
	character = new_character
	var parts: PackedStringArray = new_character.split(':')
	if character_editor and parts.size() == 2:
		character_editor.text = "%s [%s]" % [parts[1].capitalize(), parts[0].capitalize()]


func _on_set_dialogue(new_dialogue: String) -> void:
	dialogue = new_dialogue
	if dialogue_editor:
		dialogue_editor.text = dialogue
