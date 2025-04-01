@tool
# TODO: prefix with Parley
class_name DialogueOptionNode extends ParleyGraphNode

@export var character: String = "": set = _on_set_character
# TODO: rename to text
@export var option: String = "": set = _on_set_option

@onready var character_editor: Label = %Character
@onready var option_editor: Label = %DialogueOption

func _ready() -> void:
	setup(DialogueAst.Type.DIALOGUE_OPTION, 'Option')
	custom_minimum_size = Vector2(350, 250)
	clear_all_slots()
	set_slot(0, true, 0, Color.CHARTREUSE, true, 0, Color.CHARTREUSE)
	set_slot_style(0)
	_render_character()
	_render_option()

func _on_set_character(new_character: String) -> void:
	character = new_character
	_render_character()

func _on_set_option(new_option: String) -> void:
	option = new_option
	_render_option()

func _render_character() -> void:
	var parts: PackedStringArray = character.split(':')
	if character_editor and parts.size() == 2:
		character_editor.text = "%s [%s]" % [parts[1].capitalize(), parts[0].capitalize()]

func _render_option() -> void:
	if option_editor:
		option_editor.text = option
