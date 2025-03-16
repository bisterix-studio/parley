@tool
# TODO: prefix with Parley
class_name DialogueOptionNode extends ParleyGraphNode

@export var character: String = ""
@export var option: String = "" # TODO: rename to text

@onready var _character: Label = %Character
@onready var _option: Label = %DialogueOption

#############
# Lifecycle #
#############
func _ready() -> void:
	setup(DialogueAst.Type.DIALOGUE_OPTION, 'Option')
	custom_minimum_size = Vector2(350, 250)
	update(character, option)
	clear_all_slots()
	set_slot(0, true, 0, Color.CHARTREUSE, true, 0, Color.CHARTREUSE)
	set_slot_style(0)


func update(new_character: String, new_option: String) -> void:
	character = new_character
	_character.text = character
	option = new_option
	_option.text = option
